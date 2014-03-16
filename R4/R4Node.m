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
    node->_parent = nil;
    node.scene = nil;
    [_children removeObject:node];
  }];
}

- (void)removeAllChildren
{
  [_children enumerateObjectsUsingBlock:^(R4Node *node, NSUInteger idx, BOOL *stop) {
    node->_parent = nil;
    node.scene = nil;
  }];
  [_children removeAllObjects];
}

- (void)removeFromParent
{
  [_parent removeChildrenInArray:@[self]];
}

- (void)setParent:(R4Node *)parent
{
  if (_parent) {
    [self removeFromParent];
  }
  
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

- (R4Sphere)calculateAccumulatedBoundingSphere
{
  // TODO: Cache ?
  R4Sphere sphere = self.boundingSphere;
  
  for (R4Node *node in self.children) {
    R4Sphere bs = [node calculateAccumulatedBoundingSphere];
    
    GLKVector3 c1 = sphere.center;
    GLKVector3 c2 = bs.center;
    CGFloat r1 = sphere.radius;
    CGFloat r2 = bs.radius;
    
    GLKVector3 d = GLKVector3Subtract(c2, c1);
    CGFloat dd = GLKVector3Length(d);
    
    // if bs is already encompassed inside sphere
    if (dd <= r1 - r2) {
      continue;
    }
    
    // else, expand sphere to encomapss both sphere and bs
    CGFloat rn = 0.5f * (dd + r1 + r2);
    GLKVector3 cn = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(c1, c2), GLKVector3MultiplyScalar(d, (r2 - r1)/dd)), 0.5f);
    
    sphere.radius = rn;
    sphere.center = cn;
  }
  
  return sphere;
}

- (R4Sphere)boundingSphere
{
  if (_transformsDirty) {
    [self updateTransformMatrices];
  }
  
  return R4SphereMake(self->_positionWorldSpace, 0);
}

- (R4OBB)boundingBox
{
  if (_transformsDirty) {
    [self updateTransformMatrices];
  }
  
  // TODO Normalize not needed??
  return R4OBBMake(self->_positionWorldSpace, GLKVector3Normalize(GLKVector3MakeWithArray(&self->_modelMatrix.m00)), GLKVector3Normalize(GLKVector3MakeWithArray(&self->_modelMatrix.m10)), GLKVector3Normalize(GLKVector3MakeWithArray(&self->_modelMatrix.m20)), GLKVector3Make(0, 0, 0));
}

- (void)updateNodeAtTime:(NSTimeInterval)time
{
  if (self.paused) {
    return;
  }
  
  if (_transformsDirty) {
    for (R4Node *child in _children) {
      child->_transformsDirty = YES;
    }
  }
  
  for (R4Node *node in _children) {
    [node updateNodeAtTime:time];
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

- (BOOL)intersectsNode:(R4Node *)node
{
  // TODO Sphere test first
  
  // Algorithm from Real-Time Collision About the CD-ROM 593 Detection by Christer Ericson,
  // published by Morgan Kaufmann Publishers, © 2005 Elsevier Inc
  
  R4OBB a = self.boundingBox;
  R4OBB b = node.boundingBox;
  
  float ra, rb;
  GLKMatrix3 R, AbsR;
  float EPSILON = 0.00001;
  
  // Compute rotation matrix expressing b in a’s coordinate frame
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      R.m[i*3+j] = GLKVector3DotProduct(a.u[i], b.u[j]);
  
  // Compute translation vector t
  GLKVector3 tr = GLKVector3Subtract(b.c, a.c);
  
  // Bring translation into a’s coordinate frame
  GLKVector3 t = GLKVector3Make(GLKVector3DotProduct(tr, a.u[0]), GLKVector3DotProduct(tr, a.u[1]), GLKVector3DotProduct(tr, a.u[2]));
  
  // Compute common subexpressions. Add in an epsilon term to
  // counteract arithmetic errors when two edges are parallel and // their cross product is (near) null (see text for details)
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      AbsR.m[i*3+j] = ABS(R.m[i*3+j]) + EPSILON;
  
  // Test axes L = A0, L = A1, L = A2
  for (int i = 0; i < 3; i++) {
    ra = a.e.v[i];
    rb = b.e.x * AbsR.m[i*3] + b.e.y * AbsR.m[i*3+1] + b.e.z * AbsR.m[i*3+2];
    if (ABS(t.v[i]) > ra + rb) return NO;
  }
  
  // Test axes L = B0, L = B1, L = B2
  for (int i = 0; i < 3; i++) {
    ra = a.e.x * AbsR.m[i] + a.e.y * AbsR.m[3+i] + a.e.z * AbsR.m[6+i];
    rb = b.e.v[i];
    if (ABS(t.x * R.m[i] + t.y * R.m[3+i] + t.z * R.m[6+i]) > ra + rb) return NO;
  }
  
  // Test axis L = A0 x B0
  ra = a.e.v[1] * AbsR.m[6] + a.e.v[2] * AbsR.m[3];
  rb = b.e.v[1] * AbsR.m[2] + b.e.v[2] * AbsR.m[1];
  if (ABS(t.v[2] * R.m[3] - t.v[1] * R.m[6]) > ra + rb) return NO;
  
  // Test axis L = A0 x B1
  ra = a.e.v[1] * AbsR.m[7] + a.e.v[2] * AbsR.m[4];
  rb = b.e.v[0] * AbsR.m[2] + b.e.v[2] * AbsR.m[0];
  if (ABS(t.v[2] * R.m[4] - t.v[1] * R.m[7]) > ra + rb) return NO;
  
  // Test axis L = A0 x B2
  ra = a.e.v[1] * AbsR.m[8] + a.e.v[2] * AbsR.m[5];
  rb = b.e.v[0] * AbsR.m[1] + b.e.v[1] * AbsR.m[0];
  if (ABS(t.v[2] * R.m[5] - t.v[1] * R.m[8]) > ra + rb) return NO;
  
  // Test axis L = A1 x B0
  ra = a.e.v[0] * AbsR.m[6] + a.e.v[2] * AbsR.m[0];
  rb = b.e.v[1] * AbsR.m[5] + b.e.v[2] * AbsR.m[4];
  if (ABS(t.v[0] * R.m[6] - t.v[2] * R.m[0]) > ra + rb) return NO;
  
  // Test axis L = A1 x B1
  ra = a.e.v[0] * AbsR.m[7] + a.e.v[2] * AbsR.m[1];
  rb = b.e.v[0] * AbsR.m[5] + b.e.v[2] * AbsR.m[3];
  if (ABS(t.v[0] * R.m[7] - t.v[2] * R.m[1]) > ra + rb) return NO;
  
  // Test axis L = A1 x B2
  ra = a.e.v[0] * AbsR.m[8] + a.e.v[2] * AbsR.m[2];
  rb = b.e.v[0] * AbsR.m[4] + b.e.v[1] * AbsR.m[3];
  if (ABS(t.v[0] * R.m[8] - t.v[2] * R.m[2]) > ra + rb) return NO;
  
  // Test axis L = A2 x B0
  ra = a.e.v[0] * AbsR.m[3] + a.e.v[1] * AbsR.m[0];
  rb = b.e.v[1] * AbsR.m[8] + b.e.v[2] * AbsR.m[7];
  if (ABS(t.v[1] * R.m[0] - t.v[0] * R.m[3]) > ra + rb) return NO;
  
  // Test axis L = A2 x B1
  ra = a.e.v[0] * AbsR.m[4] + a.e.v[1] * AbsR.m[1];
  rb = b.e.v[0] * AbsR.m[8] + b.e.v[2] * AbsR.m[6];
  if (ABS(t.v[1] * R.m[1] - t.v[0] * R.m[4]) > ra + rb) return NO;
  
  // Test axis L = A2 x B2
  ra = a.e.v[0] * AbsR.m[5] + a.e.v[1] * AbsR.m[2];
  rb = b.e.v[0] * AbsR.m[7] + b.e.v[1] * AbsR.m[6];
  if (ABS(t.v[1] * R.m[2] - t.v[0] * R.m[5]) > ra + rb) return NO;
  
  return YES;
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

    CGFloat t;
    R4Sphere sphere = node.calculateAccumulatedBoundingSphere;
    
    if (R4SphereRayTest(sphere, ray, &t)) {
      //NSLog(@"Possible [%@] len [%f]", node.name, t);
      node->_distanceToCamera = t;
      [self.scene.view.responderChain addObject:node];
      
      R4Node *possibleHitTest = [node hitTest:ray event:event];
      if (possibleHitTest && t < maxLen) {
        hitTestNode = possibleHitTest;
        maxLen = t;
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
