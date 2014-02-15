//
//  R4LightNode.m
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4LightNodePrivate.h"

@interface R4LightNode ()
@end

@implementation R4LightNode

+ (instancetype)pointLightAtPosition:(GLKVector3)position
{
  R4LightNode *lightNode = [[[self class] alloc] init];
  lightNode.position = position;
  return lightNode;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.ambientColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    self.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
  }
  return self;
}

@end
