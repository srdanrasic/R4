//
//  R4Shader.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Shader.h"

@interface R4Shader () {
  GLuint _shaderName;
}
@property (nonatomic, assign, readwrite) R4ShaderType shaderType;
@property (nonatomic, strong, readwrite) NSDictionary *attributeMapping;
@end

@implementation R4Shader

- (instancetype)initVertexShaderWithSourceString:(NSString *)sourceString attributeMapping:(NSDictionary *)attributeMapping
{
  self = [super init];
  if (self) {
    self.shaderType = R4ShaderTypeVertex;
    if ([self compileShaderOfType:R4ShaderTypeVertex source:[sourceString cStringUsingEncoding:NSUTF8StringEncoding]]) {
      // good to go
      self.attributeMapping = attributeMapping;
    } else {
      return nil;
    }
  }
  return self;
}

- (instancetype)initFragmentShaderWithSourceString:(NSString *)sourceString attributeMapping:(NSDictionary *)attributeMapping
{
  self = [super init];
  if (self) {
    self.shaderType = R4ShaderTypeFragment;
    if ([self compileShaderOfType:R4ShaderTypeFragment source:[sourceString cStringUsingEncoding:NSUTF8StringEncoding]]) {
      // good to go
      self.attributeMapping = attributeMapping;
    } else {
      return nil;
    }
  }
  return self;
}

- (void)dealloc
{
  if (_shaderName) {
    glDeleteShader(_shaderName);
  }
}

- (BOOL)compileShaderOfType:(GLenum)type source:(const char *)source
{
  GLint status;
  
  if (!source) {
    NSLog(@"Failed to load vertex shader");
    return NO;
  }
  
  _shaderName = glCreateShader(type);
  glShaderSource(_shaderName, 1, &source, NULL);
  glCompileShader(_shaderName);
  
#if defined(DEBUG)
  GLint logLength;
  glGetShaderiv(_shaderName, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(_shaderName, logLength, &logLength, log);
    NSLog(@"Shader compile log:\n%s", log);
    free(log);
  }
#endif
  
  glGetShaderiv(_shaderName, GL_COMPILE_STATUS, &status);
  if (status == 0) {
    glDeleteShader(_shaderName);
    return NO;
  }
  
  return YES;
}

- (GLuint)shaderName
{
  return _shaderName;
}

@end
