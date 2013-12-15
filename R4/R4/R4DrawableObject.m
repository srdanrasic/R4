//
//  R4DrawableObject.m
//  R4
//
//  Created by Srđan Rašić on 15/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4DrawableObject.h"

@interface R4DrawableObject ()
@property (strong, nonatomic, readwrite) GLKBaseEffect *effect;
@end

@implementation R4DrawableObject

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.material.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    self.effect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.effect.material.specularColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    self.effect.material.shininess = 0.5;
    
    vertexBuffer = GL_INVALID_VALUE;
    indexBuffer = GL_INVALID_VALUE;
  }
  return self;
}

@end
