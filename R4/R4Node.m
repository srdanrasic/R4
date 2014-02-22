//
//  R4Node.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4NodePrivate.h"
#import "R4ScenePrivate.h"
#import "R4ViewPrivate.h"
#import "R4ActionPrivate.h"
#import "R4SceneManager.h"

@implementation R4Node

+ (instancetype)node
{
  return [[[self class] alloc] init];
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _children = [NSMutableArray array];
    _actions = [NSMutableArray array];
    _transformsDirty = YES;
    _position = GLKVector3Make(0, 0, 0);
    _scale = GLKVector3Make(1, 1, 1);
    _orientation = GLKQuaternionIdentity;
    _speed = 1.0;
    _paused = NO;
    _hidden = NO;
    _parent = nil;
    _userInteractionEnabled = NO;
    _userData = [NSMutableDictionary dictionary];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    // TODO
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  // TODO
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4Node *node = [[[self class] allocWithZone:zone] init];
  
  node.position = self.position;
  node.scale = self.scale;
  node.orientation = self.orientation;
  node.speed = self.speed;
  node.paused = self.paused;
  node.hidden = self.hidden;
  node.userInteractionEnabled = self.userInteractionEnabled;
  node.name = self.name;
  node.children = [[NSMutableArray alloc] initWithArray:self.children copyItems:YES];
  node.actions = [[NSMutableArray alloc] initWithArray:self.actions copyItems:YES];
  
  return node;
}

#pragma mark - Instance methods

- (void)setUniformScale:(CGFloat)scale
{
  _transformsDirty = YES;
  self.scale = GLKVector3Make(scale, scale, scale);
}

- (void)addChild:(R4Node *)node
{
  [_children addObject:node];
  node.parent = self;
}

- (void)insertChild:(R4Node *)node atIndex:(NSInteger)index
{
  [_children insertObject:node atIndex:index];
  node.parent = self;
}

- (void)removeChildrenInArray:(NSArray *)nodes
{
  [nodes enumerateObjectsUsingBlock:^(R4Node *node, NSUInteger idx, BOOL *stop) {
    [node setParent:nil];
    [_children removeObject:node];
  }];
}

- (void)removeAllChildren
{
  [_children enumerateObjectsUsingBlock:^(R4Node *node, NSUInteger idx, BOOL *stop) {
    [node setParent:nil];
  }];
  [_children removeAllObjects];
}

- (void)removeFromParent
{
  [self.parent removeChildrenInArray:@[self]];
}

- (void)setParent:(R4Node *)parent
{
  _parent = parent;
  self.scene = parent.scene;
}

- (R4Node *)childNodeWithName:(NSString *)name
{
  __block R4Node *child = nil;
  [_children enumerateObjectsUsingBlock:^(R4Node *node, NSUInteger idx, BOOL *stop) {
    if ([node.name isEqualToString:name]) {
      *stop = YES;
      child = node;
    }
  }];
  
  return child;
}

- (void)enumerateChildNodesWithName:(NSString *)name usingBlock:(void (^)(R4Node *, BOOL *))block
{
  for (R4Node *node in _children) {
    if ([node.name isEqualToString:name]) {
      BOOL stop = NO;
      block(node, &stop);
      if (stop) {
        break;
      }
    }
  }
}

- (BOOL)inParentHierarchy:(R4Node *)parent
{
  NSMutableArray *nodes = [parent.children mutableCopy];
  
  while (nodes.count > 0) {
    R4Node *node = nodes.firstObject;
    if (self == node) {
     return YES;
    } else {
      [nodes removeObjectAtIndex:0];
      if (node.children.count) {
        [nodes addObjectsFromArray:node.children];
      }
    };
  }
  
  return NO;
}

- (void)runAction:(R4Action *)action
{
  [self runAction:action withKey:nil completion:nil];
}

- (void)runAction:(R4Action *)action completion:(void (^)())block
{
  [self runAction:action withKey:nil completion:block];
}

- (void)runAction:(R4Action *)action withKey:(NSString *)key
{
  [self runAction:action withKey:key completion:nil];
}

- (void)runAction:(R4Action *)action withKey:(NSString *)key completion:(void (^)())block
{
  id _block = block, _key = key;
  
  if (_block == nil) _block = [NSNull null];
  if (_key == nil) _key = [NSNull null];
  
  [_actions addObject:[[R4ActionDescriptor alloc] initWithAction:action key:key block:block]];
  
  [action wasAddedToTarget:self atTime:CACurrentMediaTime()];
}

- (BOOL)hasActions
{
  return _actions.count > 0;
}

- (R4Action *)actionForKey:(NSString *)key
{
  for (R4ActionDescriptor *actionDescriptor in _actions) {
    if ([actionDescriptor.key isEqualToString:key]) {
      return actionDescriptor.action;
    }
  }
  
  return nil;
}

- (void)removeActionForKey:(NSString *)key
{
  for (NSInteger i = _actions.count - 1; i >= 0; i-- ) {
    if ([[_actions[i] key] isEqualToString:key]) {
      [[_actions[i] action] wasRemovedFromTarget:self atTime:CACurrentMediaTime()];
      [_actions removeObjectAtIndex:i];
    }
  }
}

- (void)removeAllActions
{
  for (R4ActionDescriptor *actionDescriptor in _actions) {
    [actionDescriptor.action wasRemovedFromTarget:self atTime:CACurrentMediaTime()];
  }
  
  [_actions removeAllObjects];
}

#pragma mark - Methods

- (void)setScene:(R4Scene *)scene
{
  if (_scene != scene) {
    
    if (!scene && _scene) {
      [_scene.sceneManager nodeRemoved:self];
    } else if (!_scene && scene) {
      [scene.sceneManager nodeAdded:self];
    }
    
    _scene = scene;
    
    for (R4Node *node in _children) {
      node.scene = scene;
    }
  }
}

- (void)setPaused:(BOOL)paused
{
  if (self.parent && self.parent.paused && !paused) {
    return; // if parent is paused, I must not resume myself!
  }
  
  if (self.paused != paused) {
    _paused = paused;

    for (R4Node *node in self.children) {
      [node setPaused:paused];
    }
    
    NSTimeInterval time = CACurrentMediaTime();
    if (_paused) {
      for (R4ActionDescriptor *actionDescriptor in _actions) {
        [actionDescriptor.action wasPausedWithTarget:self atTime:time];
      }
    } else {
      for (R4ActionDescriptor *actionDescriptor in _actions) {
        [actionDescriptor.action willResumeWithTarget:self atTime:time];
      }
    }

  }
}

- (void)setPosition:(GLKVector3)position
{
  _transformsDirty = YES;
  _position = position;
}

- (void)setScale:(GLKVector3)scale
{
  _transformsDirty = YES;
  _scale = scale;
}

- (void)setOrientation:(GLKQuaternion)orientation
{
  _transformsDirty = YES;
  _orientation = orientation;
}

- (void)updateTransformMatrices
{
  GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z);
  modelMatrix = GLKMatrix4Multiply(modelMatrix, GLKMatrix4MakeWithQuaternion(self.orientation));
  modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale.x, self.scale.y, self.scale.z);
  
  if (self.parent) {
    modelMatrix = GLKMatrix4Multiply(self.parent.modelMatrix, modelMatrix);
  }
  
  _modelMatrix = modelMatrix;
  _invModelMatrix = GLKMatrix4Invert(_modelMatrix, NULL);
  _positionWorldSpace = GLKVector3MakeWithArray(GLKMatrix4MultiplyVector4(_modelMatrix, GLKVector4Make(0, 0, 0, 1.f)).v);
  _transformsDirty = NO;
  
  for (R4Node *child in _children) {
    child->_transformsDirty = YES;
  }
}

- (GLKMatrix4)modelMatrix
{
  if (_transformsDirty) {
    [self updateTransformMatrices];
  }
  
  return _modelMatrix;
}

- (GLKMatrix4)invModelMatrix
{
  if (_transformsDirty) {
    [self updateTransformMatrices];
  }
  
  return _invModelMatrix;
}

- (GLKVector3)positionWorldSpace
{
  if (_transformsDirty) {
    [self updateTransformMatrices];
  }
  
  return _positionWorldSpace;
}

- (R4Box)calculateAccumulatedBoundingBox
{
  GLKVector3 min = GLKVector3MakeWithArray(GLKMatrix4MultiplyVector4(self.modelMatrix, GLKVector4MakeWithVector3(self.boundingBox.min, 1.0)).v);
  GLKVector3 max = GLKVector3MakeWithArray(GLKMatrix4MultiplyVector4(self.modelMatrix, GLKVector4MakeWithVector3(self.boundingBox.max, 1.0)).v);

  _accumulatedBoundingBox.min = GLKVector3Minimum(min, max);
  _accumulatedBoundingBox.max = GLKVector3Maximum(min, max);
  
  for (R4Node *node in self.children) {
    R4Box bb = [node calculateAccumulatedBoundingBox];
    _accumulatedBoundingBox.min = GLKVector3Minimum(_accumulatedBoundingBox.min, bb.min);
    _accumulatedBoundingBox.max = GLKVector3Maximum(_accumulatedBoundingBox.max, bb.max);
  }
  
  return _accumulatedBoundingBox;
}

- (R4Box)boundingBox
{
  return R4BoxZero;
}

- (void)updateActionsAtTime:(NSTimeInterval)time
{
  if (self.paused) {
    return;
  }
  
  for (R4Node *node in _children) {
    [node updateActionsAtTime:time];
  }
  
  for (NSInteger i = _actions.count - 1; i >= 0; i--) {
    R4ActionDescriptor *actionDescriptor = _actions[i];
    
    if (!actionDescriptor.started) {
      [actionDescriptor.action willStartWithTarget:self atTime:time];
      actionDescriptor.started = YES;
    }
    
    [actionDescriptor.action updateWithTarget:self forTime:time];
    
    if (actionDescriptor.action.finished) {
      [_actions removeObjectAtIndex:i];
      [actionDescriptor.action wasRemovedFromTarget:self atTime:CACurrentMediaTime()];
    }
  }
}

- (GLKVector3)convertPoint:(GLKVector3)point toNode:(R4Node *)node
{
  GLKMatrix4 transform = GLKMatrix4Multiply(node.invModelMatrix, self.modelMatrix);
  GLKVector4 point4 = GLKMatrix4MultiplyVector4(transform, GLKVector4MakeWithVector3(point, 1.0));
  return GLKVector3MakeWithArray(point4.v);
}

- (GLKVector3)convertPoint:(GLKVector3)point fromNode:(R4Node *)node
{
  GLKMatrix4 transform = GLKMatrix4Multiply(self.invModelMatrix, node.modelMatrix);
  GLKVector4 point4 = GLKMatrix4MultiplyVector4(transform, GLKVector4MakeWithVector3(point, 1.0));
  return GLKVector3MakeWithArray(point4.v);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"Node named [%@] at [%@]", self.name, NSStringFromGLKVector3(self.position)];
}

#pragma mark - UIResponder overrides

- (R4Node *)hitTest:(R4Ray)ray event:(UIEvent *)event
{
  //GLKVector3 o = ray.startPoint;
  CGFloat maxLen = CGFLOAT_MAX;
  R4Node *hitTestNode = self;
  
  for (R4Node *node in self.children) {
    if (!node.userInteractionEnabled) {
      continue;
    }

    GLKVector3 invDirection = GLKVector3Make(1.f/ray.direction.x, 1.f/ray.direction.y, 1.f/ray.direction.z);
    R4Box bb = node.calculateAccumulatedBoundingBox;
    BOOL intersects = NO;
    CGFloat distance;
    
    // lb is the corner of AABB with minimal coordinates - left bottom, rt is maximal corner
    // r.org is origin of ray
    float t1 = (bb.min.x - ray.startPoint.x) * invDirection.x;
    float t2 = (bb.max.x - ray.startPoint.x) * invDirection.x;
    float t3 = (bb.min.y - ray.startPoint.y) * invDirection.y;
    float t4 = (bb.max.y - ray.startPoint.y) * invDirection.y;
    float t5 = (bb.min.z - ray.startPoint.z) * invDirection.z;
    float t6 = (bb.max.z - ray.startPoint.z) * invDirection.z;
    
    float tmin = MAX(MAX(MIN(t1, t2), MIN(t3, t4)), MIN(t5, t6));
    float tmax = MIN(MIN(MAX(t1, t2), MAX(t3, t4)), MAX(t5, t6));
    
    // if tmax < 0, ray (line) is intersecting AABB, but whole AABB is behing us
    if (tmax < 0) {
      distance = tmax;
    } else if (tmin > tmax) { // if tmin > tmax, ray doesn't intersect AABB
      distance = tmax;
    } else {
      distance = tmin;
      intersects = YES;
    }
    
    if (intersects) {
      //NSLog(@"Possible [%@] len [%f]", node.name, distance);
      node->_distanceToCamera = distance;
      [self.scene.view.responderChain addObject:node];
      
      R4Node *possibleHitTest = [node hitTest:ray event:event];
      if (possibleHitTest && distance < maxLen) {
        hitTestNode = possibleHitTest;
        maxLen = distance;
      }
    } else {
      //NSLog(@"Not possible [%@]", node.name);
      node->_distanceToCamera = -1;
    }
  }
  
  return hitTestNode;
}

- (UIResponder *)nextResponder
{
  NSInteger idx = [self.scene.view.responderChain indexOfObject:self];
  if (idx != NSNotFound && idx > 0) {
    return [self.scene.view.responderChain objectAtIndex:idx-1];
  }
  return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[self nextResponder] touchesCancelled:touches withEvent:event];
}

@end

#pragma mark - UITouch Additions

@implementation UITouch (R4NodeTouches)

- (GLKVector3)locationInNode:(R4Node *)node onPlane:(GLKVector3)planeNormal
{
  R4Ray ray = [node.scene.view convertPoint:[self locationInView:node.scene.view] toScene:node.scene];
  GLfloat d = GLKVector3DotProduct(GLKVector3Negate(ray.startPoint), planeNormal) / GLKVector3DotProduct(ray.direction, planeNormal);
  GLKVector3 worldPosition = GLKVector3Add(ray.startPoint, GLKVector3MultiplyScalar(ray.direction, d));
  GLKVector4 nodePosition4 = GLKMatrix4MultiplyVector4(node.invModelMatrix, GLKVector4MakeWithVector3(worldPosition, 1.f));
  return GLKVector3MakeWithArray(nodePosition4.v);
}

- (GLKVector3)previousLocationInNode:(R4Node *)node onPlane:(GLKVector3)planeNormal
{
  R4Ray ray = [node.scene.view convertPoint:[self previousLocationInView:node.scene.view] toScene:node.scene];
  GLfloat d = GLKVector3DotProduct(GLKVector3Negate(ray.startPoint), planeNormal) / GLKVector3DotProduct(ray.direction, planeNormal);
  GLKVector3 worldPosition = GLKVector3Add(ray.startPoint, GLKVector3MultiplyScalar(ray.direction, d));
  GLKVector4 nodePosition4 = GLKMatrix4MultiplyVector4(node.invModelMatrix, GLKVector4MakeWithVector3(worldPosition, 1.f));
  return GLKVector3MakeWithArray(nodePosition4.v);
}

@end
