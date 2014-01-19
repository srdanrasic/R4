//
//  R4Program.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Program.h"
#import "R4Shader.h"

@interface R4Program () {
  GLuint _programName;
}
@property (nonatomic, strong, readwrite) NSDictionary *uniforms;
@end


@implementation R4Program

- (instancetype)initWithVertexShader:(R4Shader *)vsh fragmentShader:(R4Shader *)fsh
{
  NSAssert(vsh && vsh.shaderType == R4ShaderTypeVertex, @"No vertex shader or invalid type");
  NSAssert(fsh && fsh.shaderType == R4ShaderTypeFragment, @"No fragment shader or invalid type");
  self = [super init];
  if (self) {
    GLuint vertShader = vsh.shaderName;
    GLuint fragShader = fsh.shaderName;
    
    // Create shader program.
    GLuint program = glCreateProgram();

    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind vertex shader attribute locations.
    for (NSString *attributeName in vsh.attributeMapping.allKeys) {
      NSNumber *location = [vsh.attributeMapping objectForKey:attributeName];
      glBindAttribLocation(program, [location integerValue], [attributeName cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    // Bind fragment shader attribute locations.
    for (NSString *attributeName in fsh.attributeMapping.allKeys) {
      NSNumber *location = [fsh.attributeMapping objectForKey:attributeName];
      glBindAttribLocation(program, [location integerValue], [attributeName cStringUsingEncoding:NSUTF8StringEncoding]);
    }

    // Link program.
    if (![self linkProgram:program]) {
      NSLog(@"Failed to link program: %d", program);
      
      if (program) {
        glDetachShader(program, vertShader);
        glDetachShader(program, fragShader);
        glDeleteProgram(program);
        program = 0;
      }
      
      return nil;
    }
    
    // Get uniform locations.
    GLint numActiveUniforms = 0;
    glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &numActiveUniforms);
    
    GLint maxUniformNameLength = 0;
    glGetProgramiv(program, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniformNameLength);
    GLchar *nameData = malloc(sizeof(GLchar) * maxUniformNameLength);
    
    NSMutableDictionary *uniforms = [NSMutableDictionary dictionary];

    for(int unif = 0; unif < numActiveUniforms; ++unif) {
      GLint arraySize = 0;
      GLenum type = 0;
      GLsizei actualLength = 0;
      glGetActiveUniform(program, unif, maxUniformNameLength, &actualLength, &arraySize, &type, nameData);
      NSString *name = [NSString stringWithCString:nameData encoding:NSUTF8StringEncoding];
      
      GLint loc = glGetUniformLocation(program, nameData);
      [uniforms setObject:@(loc) forKey:name];
      
      // IDEA: Generete block that sets up all known uniforms 
    }
    
    self.uniforms = uniforms;
    
    // Release vertex and fragment shaders.
    if (vertShader) {
      glDetachShader(program, vertShader);
    }
    if (fragShader) {
      glDetachShader(program, fragShader);
    }
    
    _programName = program;
  }
  return self;
}

- (void)dealloc
{
  if (_programName) {
    glDeleteProgram(_programName);
  }
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

- (GLuint)programName
{
  return _programName;
}

- (void)setUniform1f:(NSString *)name v0:(GLfloat)v0
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform1f([location integerValue], v0);
}

- (void)setUniform2f:(NSString *)name v0:(GLfloat)v0 v1:(GLfloat)v1
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform2f([location integerValue], v0, v1);
}

- (void)setUniform3f:(NSString *)name v0:(GLfloat)v0 v1:(GLfloat)v1 v2:(GLfloat)v2
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform3f([location integerValue], v0, v1, v2);
}
- (void)setUniform4f:(NSString *)name v0:(GLfloat)v0 v1:(GLfloat)v1 v2:(GLfloat)v2 v3:(GLfloat)v3
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform4f([location integerValue], v0, v1, v2, v3);
}

- (void)setUniform1i:(NSString *)name v0:(GLint)v0
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform1i([location integerValue], v0);
}

- (void)setUniform2i:(NSString *)name v0:(GLint)v0 v1:(GLint)v1
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform2i([location integerValue], v0, v1);
}

- (void)setUniform3i:(NSString *)name v0:(GLint)v0 v1:(GLint)v1 v2:(GLint)v2
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform3i([location integerValue], v0, v1, v2);
}

- (void)setUniform4i:(NSString *)name v0:(GLint)v0 v1:(GLint)v1 v2:(GLint)v2 v3:(GLint)v3
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform4i([location integerValue], v0, v1, v2, v3);
}

- (void)setUniform1fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform1fv([location integerValue], count, v);
}

- (void)setUniform2fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform2fv([location integerValue], count, v);
}

- (void)setUniform3fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform3fv([location integerValue], count, v);
}

- (void)setUniform4fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform4fv([location integerValue], count, v);
}

- (void)setUniform1iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform1iv([location integerValue], count, v);
}

- (void)setUniform2iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform2iv([location integerValue], count, v);
}

- (void)setUniform3iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform3iv([location integerValue], count, v);
}

- (void)setUniform4iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniform4iv([location integerValue], count, v);
}

- (void)setUniformMatrix2fv:(NSString *)name count:(GLsizei)count transpose:(GLboolean)transpose v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniformMatrix2fv([location integerValue], count, transpose, v);
}

- (void)setUniformMatrix3fv:(NSString *)name count:(GLsizei)count transpose:(GLboolean)transpose v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniformMatrix3fv([location integerValue], count, transpose, v);
}

- (void)setUniformMatrix4fv:(NSString *)name count:(GLsizei)count transpose:(GLboolean)transpose v:(const GLfloat *)v
{
  NSNumber *location = [_uniforms objectForKey:name];
  NSAssert1(location, @"No uniform named [%@]", name);
  glUniformMatrix4fv([location integerValue], count, transpose, v);
}

@end
