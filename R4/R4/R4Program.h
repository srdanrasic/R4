//
//  R4Program.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Shader;

@interface R4Program : NSObject

@property (nonatomic, assign, readonly) GLuint programName;
@property (nonatomic, strong, readonly) NSDictionary *autoUniforms;

- (instancetype)initWithVertexShader:(R4Shader *)vsh fragmentShader:(R4Shader *)fsh;

@end
