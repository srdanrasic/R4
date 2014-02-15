//
//  R4Program.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Shader;

/*!
 R4Program encapsulates OpenGL Program object. Creation of this object is usually done internally by R4Pass.
 
 @warning You should never instantiate R4Program objects directly, rather R4ProgramManager should be used to create new programs.
 */
@interface R4Program : NSObject

@property (nonatomic, assign, readonly) GLuint programName;
@property (nonatomic, strong, readonly) NSDictionary *uniforms;

- (instancetype)initWithVertexShader:(R4Shader *)vsh fragmentShader:(R4Shader *)fsh;

- (void)setUniform1f:(NSString *)name v0:(GLfloat)v0;
- (void)setUniform2f:(NSString *)name v0:(GLfloat)v0 v1:(GLfloat)v1;
- (void)setUniform3f:(NSString *)name v0:(GLfloat)v0 v1:(GLfloat)v1 v2:(GLfloat)v2;
- (void)setUniform4f:(NSString *)name v0:(GLfloat)v0 v1:(GLfloat)v1 v2:(GLfloat)v2 v3:(GLfloat)v3;

- (void)setUniform1i:(NSString *)name v0:(GLint)v0;
- (void)setUniform2i:(NSString *)name v0:(GLint)v0 v1:(GLint)v1;
- (void)setUniform3i:(NSString *)name v0:(GLint)v0 v1:(GLint)v1 v2:(GLint)v2;
- (void)setUniform4i:(NSString *)name v0:(GLint)v0 v1:(GLint)v1 v2:(GLint)v2 v3:(GLint)v3;

- (void)setUniform1fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v;
- (void)setUniform2fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v;
- (void)setUniform3fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v;
- (void)setUniform4fv:(NSString *)name count:(GLsizei)count v:(const GLfloat *)v;

- (void)setUniform1iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v;
- (void)setUniform2iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v;
- (void)setUniform3iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v;
- (void)setUniform4iv:(NSString *)name count:(GLsizei)count v:(const GLint *)v;

- (void)setUniformMatrix2fv:(NSString *)name count:(GLsizei)count transpose:(GLboolean)transpose v:(const GLfloat *)v;
- (void)setUniformMatrix3fv:(NSString *)name count:(GLsizei)count transpose:(GLboolean)transpose v:(const GLfloat *)v;
- (void)setUniformMatrix4fv:(NSString *)name count:(GLsizei)count transpose:(GLboolean)transpose v:(const GLfloat *)v;

@end
