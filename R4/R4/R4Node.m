//
//  R4Node.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node_Private.h"
#import "R4Scene_Private.h"
#import "R4View_Private.h"

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
  }
  return self;
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
  [self runAction:action completion:nil];
}

- (void)runAction:(R4Action *)action completion:(void (^)())block
{
  [_actions addObject:action];
  // TODO
}

- (void)runAction:(R4Action *)action withKey:(NSString *)key
{
  // TODO
}

- (BOOL)hasActions
{
  return _actions.count > 0;
}

- (R4Action *)actionForKey:(NSString *)key
{
  // TODO
  return nil;
}

- (void)removeActionForKey:(NSString *)key
{
  // TODO
}

- (void)removeAllActions
{
  // TODO
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

#pragma mark - Private methods

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
  if (1) {
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
    leftAxis = GLKVector3MultiplyScalar(leftAxis, self.boundingRadius);
    leftAxis = GLKMatrix4MultiplyAndProjectVector3(modelViewProjectionMatrix, GLKVector3Add(self.position, leftAxis));
    
    GLKVector3 upAxis = GLKVector3MakeWithArray(GLKMatrix4GetColumn(self.parent.modelViewMatrix, 1).v);
    upAxis = GLKVector3MultiplyScalar(upAxis, self.boundingRadius);
    upAxis = GLKMatrix4MultiplyAndProjectVector3(modelViewProjectionMatrix, GLKVector3Add(self.position, upAxis));
    
    GLKVector3 sizeX = GLKVector3Subtract(leftAxis, startPoint);
    GLKVector3 sizeY = GLKVector3Subtract(upAxis, startPoint);
    _accumulatedFrame = CGRectMake(startPoint.x - sizeX.x/2.0f, startPoint.y - sizeY.y/2.0f, sizeX.x, sizeY.y);
  }
  
  return _accumulatedFrame;
}

- (CGFloat)boundingRadius
{
  return 10;
}

- (void)willTraverse
{
}

- (void)draw
{
}

- (void)didTraverse
{
}

@end
