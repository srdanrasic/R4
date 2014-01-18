//
//  R4GPUProgram.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4GPUProgram.h"
#import "R4Base.h"

@interface R4GPUProgram () {
  GLuint _programName;
}

@property (nonatomic, strong, readwrite) NSDictionary *autoUniforms;
@property (nonatomic, strong, readwrite) NSArray *attributes;
@end

@implementation R4GPUProgram




- (instancetype)initWithVshSource:(const char *)vshSource fshSource:(const char *)fshSource
{
  NSAssert(vshSource != nil, @"Vertex shader source must be provided.");
  NSAssert(fshSource != nil, @"Fragment shader source must be provided.");
  
  self = [super init];
  if (self) {
    NSMutableDictionary *autoUniforms = [NSMutableDictionary dictionary];
    NSMutableArray *attributes = [NSMutableArray array];
    
    GLuint vertShader, fragShader;
    
    // Create shader program.
    GLuint program = glCreateProgram();
    
    // Create and compile vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vshSource]) {
      NSLog(@"Failed to compile vertex shader");
      return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:fshSource]) {
      NSLog(@"Failed to compile fragment shader");
      return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    GLint numActiveAttribs = 0;
    glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &numActiveAttribs);
    
    GLint maxAttribNameLength = 0;
    glGetProgramiv(program, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxAttribNameLength);
    GLchar *nameData = malloc(sizeof(GLchar) * maxAttribNameLength);
    
    for(int attrib = 0; attrib < numActiveAttribs; ++attrib) {
      GLint arraySize = 0;
      GLenum type = 0;
      GLsizei actualLength = 0;
      glGetActiveAttrib(program, attrib, maxAttribNameLength, &actualLength, &arraySize, &type, nameData);
      NSString *name = [NSString stringWithCString:nameData encoding:NSUTF8StringEncoding];
      
      NSInteger loc = attributeLocationForName(name);
      NSAssert1(loc != -1, @"Unknown attribute [%@]", name);
      glBindAttribLocation(program, loc, nameData);
      [attributes addObject:name];
    }
    
    self.attributes = attributes;
    free(nameData);
    
    // Link program.
    if (![self linkProgram:program]) {
      NSLog(@"Failed to link program: %d", program);
      
      if (vertShader) {
        glDeleteShader(vertShader);
        vertShader = 0;
      }
      if (fragShader) {
        glDeleteShader(fragShader);
        fragShader = 0;
      }
      if (program) {
        glDeleteProgram(program);
        program = 0;
      }
      
      return NO;
    }
    
    // Get uniform locations.
    GLint numActiveUniforms = 0;
    glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &numActiveUniforms);
    
    GLint maxUniformNameLength = 0;
    glGetProgramiv(program, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniformNameLength);
    nameData = malloc(sizeof(GLchar) * maxUniformNameLength);
    
    for(int unif = 0; unif < numActiveUniforms; ++unif) {
      GLint arraySize = 0;
      GLenum type = 0;
      GLsizei actualLength = 0;
      glGetActiveUniform(program, unif, maxUniformNameLength, &actualLength, &arraySize, &type, nameData);
      NSString *name = [NSString stringWithCString:nameData encoding:NSUTF8StringEncoding];
      
      GLint loc = glGetUniformLocation(program, nameData);
      [autoUniforms setObject:@(loc) forKey:name];
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
      glDetachShader(program, vertShader);
      glDeleteShader(vertShader);
    }
    if (fragShader) {
      glDetachShader(program, fragShader);
      glDeleteShader(fragShader);
    }
    
    _programName = program;
  }
  return self;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(const char *)source
{
  GLint status;
  
  if (!source) {
    NSLog(@"Failed to load vertex shader");
    return NO;
  }
  
  *shader = glCreateShader(type);
  glShaderSource(*shader, 1, &source, NULL);
  glCompileShader(*shader);
  
#if defined(DEBUG)
  GLint logLength;
  glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(*shader, logLength, &logLength, log);
    NSLog(@"Shader compile log:\n%s", log);
    free(log);
  }
#endif
  
  glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
  if (status == 0) {
    glDeleteShader(*shader);
    return NO;
  }
  
  return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
  GLint status;
  glLinkProgram(prog);
  
#if defined(DEBUG)
  GLint logLength;
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program link log:\n%s", log);
    free(log);
  }
#endif
  
  glGetProgramiv(prog, GL_LINK_STATUS, &status);
  if (status == 0) {
    return NO;
  }
  
  return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
  GLint logLength, status;
  
  glValidateProgram(prog);
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program validate log:\n%s", log);
    free(log);
  }
  
  glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
  if (status == 0) {
    return NO;
  }
  
  return YES;
}

@end
