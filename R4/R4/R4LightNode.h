//
//  R4LightNode.h
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@interface R4LightNode : R4Node

+ (instancetype)pointLightAtPosition:(GLKVector3)position;
+ (instancetype)directionalLightWithDirection:(GLKVector3)direction;
+ (instancetype)spotLightAtPosition:(GLKVector3)position direction:(GLKVector3)direction cutOff:(CGFloat)cutOff;

@property (nonatomic, assign) GLKVector3   direction;       // not used for point light
@property (nonatomic, assign) GLKVector4   ambientColor;    // { 0.0, 0.0, 0.0, 1.0 }
@property (nonatomic, assign) GLKVector4   diffuseColor;    // { 1.0, 1.0, 1.0, 1.0 }
@property (nonatomic, assign) GLKVector4   specularColor;   // { 1.0, 1.0, 1.0, 1.0 }
@property (nonatomic, assign) GLKVector3   spotDirection;
@property (nonatomic, assign) GLfloat      spotExponent;    // 0.0
@property (nonatomic, assign) GLfloat      spotCutoff;
@property (nonatomic, assign) GLfloat      constantAttenuation;   // 1.0
@property (nonatomic, assign) GLfloat      linearAttenuation;     // 0.0
@property (nonatomic, assign) GLfloat      quadraticAttenuation;  // 0.0

@property (nonatomic, strong, readonly) NSMutableSet *affectedNodes;  // all if empty

@end
