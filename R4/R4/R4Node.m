//
//  R4Node.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node_private.h"
#import "R4Scene_private.h"
#import "R4View_private.h"
#import "R4Action_private.h"

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
  return CGRectContainsPoint(self.calculateAccumulatedFrame, p);
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

- (R4Scene *)scene
{
  R4Node *node = self;
  while (node) {
    if ([node isKindOfClass:[R4Scene class]]) {
      return (R4Scene *)node;
    } else {
      node = node.parent;
    }
  }
  return nil;
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

- (CGRect)calculateAccumulatedFrame
{
  if (_dirty) {
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.scene.view.projectionMatrix, self.parent.modelViewMatrix);
    GLKVector3 startPoint = GLKMatrix4MultiplyAndProjectVector3(modelViewProjectionMatrix, self.position);
  
    GLKVector3 leftAxis = GLKVector3MakeWithArray(GLKMatrix4GetColumn(self.parent.modelViewMatrix, 0).v);
    leftAxis = GLKVector3MultiplyScalar(leftAxis, self.boundingBox.max.x);
    leftAxis = GLKMatrix4MultiplyAndProjectVector3(modelViewProjectionMatrix, GLKVector3Add(self.position, leftAxis));
    
    GLKVector3 upAxis = GLKVector3MakeWithArray(GLKMatrix4GetColumn(self.parent.modelViewMatrix, 1).v);
    upAxis = GLKVector3MultiplyScalar(upAxis, self.boundingBox.max.x);
    upAxis = GLKMatrix4MultiplyAndProjectVector3(modelViewProjectionMatrix, GLKVector3Add(self.position, upAxis));
    
    GLKVector3 sizeX = GLKVector3Subtract(leftAxis, startPoint);
    GLKVector3 sizeY = GLKVector3Subtract(upAxis, startPoint);
    _accumulatedFrame = CGRectMake(startPoint.x - sizeX.x/2.0f, startPoint.y - sizeY.y/2.0f, sizeX.x, sizeY.y);
  }
  
  return _accumulatedFrame;
}

- (R4Box)boundingBox
{
  return R4BoxZero;
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

@end
