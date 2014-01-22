//
//  R4LightNode.m
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4LightNodePrivate.h"

@interface R4LightNode ()
@property (nonatomic, assign) BOOL isDirectional;
@property (nonatomic, strong, readwrite) NSMutableSet *affectedNodes;
@end

@implementation R4LightNode

+ (instancetype)pointLightAtPosition:(GLKVector3)position
{
  R4LightNode *lightNode = [[[self class] alloc] init];
  lightNode.position = position;
  return lightNode;
}

+ (instancetype)directionalLightWithDirection:(GLKVector3)direction
{
  R4LightNode *lightNode = [[[self class] alloc] init];
  lightNode.direction = direction;
  lightNode.isDirectional = YES;
  return lightNode;
}

+ (instancetype)spotLightAtPosition:(GLKVector3)position direction:(GLKVector3)direction cutOff:(CGFloat)cutOff
{
  R4LightNode *lightNode = [[[self class] alloc] init];
  lightNode.position = position;
  lightNode.spotDirection = direction;
  lightNode.spotCutoff = cutOff;
  return lightNode;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.ambientColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.constantAttenuation = 1.0;
    self.spotCutoff = 180.0;
    self.affectedNodes = [NSMutableSet set];
  }
  return self;
}

- (GLKVector4)homogeneousPosition
{
  if (self.isDirectional) {
    return GLKVector4MakeWithVector3(self.direction, 0.0f);
  } else {
    return GLKVector4MakeWithVector3(self.position, 1.0f);
  }
}

- (GLKVector3)position
{
  return GLKVector3MakeWithArray(GLKMatrix4MultiplyVector4(self.parent.modelViewMatrix, GLKVector4MakeWithVector3([super position], 1.0)).v);
}

@end
