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

@implementation R4Node

+ (instancetype)node
{
  return [[R4Node alloc] init];
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _children = [NSMutableArray array];
    _actions = [NSMutableArray array];
    _dirty = YES;
    _position = GLKVector3Make(0, 0, 0);
    _scale = GLKVector3Make(1, 1, 1);
    _orientation = GLKQuaternionIdentity;
    _speed = 1.0;
    _alpha = 1.0;
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
  node.alpha = self.alpha;
  node.paused = self.paused;
  node.hidden = self.hidden;
  node.userInteractionEnabled = node.userInteractionEnabled;
  node.name = self.name;
  node.children = [[NSMutableArray alloc] initWithArray:self.children copyItems:YES];
  node.actions = [[NSMutableArray alloc] initWithArray:self.actions copyItems:YES];
  
  return node;
}

#pragma mark - Instance methods

- (void)setUniformScale:(CGFloat)scale
{
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
  _scene = parent.scene;
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

- (BOOL)containsPoint:(CGPoint)p
{
  return NO; // TODO //CGRectContainsPoint(self.calculateAccumulatedFrame, p);
}

- (R4Node *)nodeAtPoint:(CGPoint)p
{
  NSArray *nodes = [self nodesAtPoint:p];
  return [nodes lastObject];
}

- (NSArray *)nodesAtPoint:(CGPoint)p
{
  NSMutableArray *nodes = [NSMutableArray array];
  NSMutableArray *nodesToCheck = [_children mutableCopy];
  
  while (nodesToCheck.count > 0) {
    R4Node *node = nodesToCheck.firstObject;
    if ([node containsPoint:p]) { [nodes addObject:node]; }
    [nodesToCheck removeObjectAtIndex:0];
    if (node.children.count) {
      [nodesToCheck addObjectsFromArray:node.children];
    }
  }
  
  return nodes;
}

#pragma mark -  methods

- (void)setScene:(R4Scene *)scene
{
  if (_scene != scene) {
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
  _position = position;
  _dirty = YES;
}

- (void)setScale:(GLKVector3)scale
{
  _scale = scale;
  _dirty = YES;
}

- (void)setOrientation:(GLKQuaternion)orientation
{
  _orientation = orientation;
  _dirty = YES;
}

- (GLKMatrix4)modelViewMatrix
{
  if (1) { // if dirty 
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(self.orientation));
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, self.scale.x, self.scale.y, self.scale.z);

    if (self.parent) {
      modelViewMatrix = GLKMatrix4Multiply(self.parent.modelViewMatrix, modelViewMatrix);
    }
    
    _modelViewMatrix = modelViewMatrix;
    _dirty = NO;
  }
  
  return _modelViewMatrix;
}

- (R4Box)calculateAccumulatedFrame
{
  GLKVector3 min = GLKVector3MakeWithArray(GLKMatrix4MultiplyVector4(self.modelViewMatrix, GLKVector4MakeWithVector3(self.boundingBox.min, 1.0)).v);
  GLKVector3 max = GLKVector3MakeWithArray(GLKMatrix4MultiplyVector4(self.modelViewMatrix, GLKVector4MakeWithVector3(self.boundingBox.max, 1.0)).v);

  _accumulatedFrame.min = GLKVector3Minimum(min, max);
  _accumulatedFrame.max = GLKVector3Maximum(min, max);
  
  for (R4Node *node in self.children) {
    R4Box bb = [node calculateAccumulatedFrame];
    _accumulatedFrame.min = GLKVector3Minimum(_accumulatedFrame.min, bb.min);
    _accumulatedFrame.max = GLKVector3Maximum(_accumulatedFrame.max, bb.max);
  }
  
  if ([self.name isEqualToString:@"stacyBase"]) {
    NSLog(@"StacB BB: %@", NSStringFromR4Box(_accumulatedFrame));
    NSLog(@"StacY BB: %@", NSStringFromR4Box([self childNodeWithName:@"stacy"]->_accumulatedFrame));
  }
  
  return _accumulatedFrame;
}

- (R4Box)boundingBox
{
  return R4BoxZero;
}

- (GLKVector3)wsPosition
{
  if (self.parent) {
    GLKVector4 wsPos = GLKMatrix4MultiplyVector4(self.modelViewMatrix, GLKVector4Make(0.f, 0.f, 0.f, 1.f));
    return GLKVector3MakeWithArray(wsPos.v);
  } else {
    return self.position;
  }
}

- (void)willTraverse
{
}

- (void)prepareEffect:(GLKBaseEffect *)effect
{
}

- (void)draw
{
}

- (void)didTraverse
{
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
  if ([node.children containsObject:self]) {
    return GLKVector3Add(node.position, point);
  } else {
    return point;
  }
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"Node named [%@] at [%@]", self.name, NSStringFromGLKVector3(self.wsPosition)];
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
    R4Box bb = node.calculateAccumulatedFrame;
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
      NSLog(@"Possible [%@] len [%f]", node.name, distance);
      node->_distanceToCamera = distance;
      [self.scene.view.responderChain addObject:node];
      
      R4Node *possibleHitTest = [node hitTest:ray event:event];
      if (possibleHitTest && distance < maxLen) {
        hitTestNode = possibleHitTest;
        maxLen = distance;
      }
    } else {
      NSLog(@"Not possible [%@]", node.name);
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
