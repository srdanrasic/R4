//
//  R4LightNode.h
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@interface R4LightNode : R4Node

@property (nonatomic, assign) GLKVector4   ambientColor;    // { 0.0, 0.0, 0.0, 1.0 }
@property (nonatomic, assign) GLKVector4   diffuseColor;    // { 1.0, 1.0, 1.0, 1.0 }
@property (nonatomic, assign) GLKVector4   specularColor;   // { 1.0, 1.0, 1.0, 1.0 }

+ (instancetype)pointLightAtPosition:(GLKVector3)position;

@end
