//
//  R4Shader.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

typedef NS_ENUM(GLenum, R4ShaderType) {
  R4ShaderTypeFragment = GL_FRAGMENT_SHADER,
  R4ShaderTypeVertex = GL_VERTEX_SHADER
};

@interface R4Shader : NSObject

@property (nonatomic, assign, readonly) R4ShaderType shaderType;
@property (nonatomic, assign, readonly) GLuint shaderName;
@property (nonatomic, assign, readonly) NSDictionary *attributeMapping;

- (instancetype)initVertexShaderWithSourceString:(NSString *)sourceString attributeMapping:(NSDictionary *)attributeMapping;
- (instancetype)initFragmentShaderWithSourceString:(NSString *)sourceString attributeMapping:(NSDictionary *)attributeMapping;

@end
