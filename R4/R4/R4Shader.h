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

/*!
 R4Shader encapsulates OpenGL Shader object.
 
 @discussion When creating new shader, you have to provide mapping dictionary for any attribute used in the shader. Keys are attribute names as in shader source, values are NSNumber objects created from R4VertexAttribute enum, e.g. @{ @"position_modelspace": @(R4VertexAttributePositionModelSpace) }
 
 @warning You should not instantiate R4Shader objects directly, rather R4ProgramManager should be used to create new shaders.
 */

@interface R4Shader : NSObject

@property (nonatomic, assign, readonly) GLuint shaderName;
@property (nonatomic, assign, readonly) R4ShaderType shaderType;
@property (nonatomic, strong, readonly) NSDictionary *attributeMapping;

- (instancetype)initVertexShaderWithSourceString:(NSString *)sourceString attributeMapping:(NSDictionary *)attributeMapping;
- (instancetype)initFragmentShaderWithSourceString:(NSString *)sourceString attributeMapping:(NSDictionary *)attributeMapping;

@end
