//
//  R4ProgramManager.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4ProgramManager.h"
#import "R4BuildTimeShaders.h"
#import "R4Program.h"
#import "R4Shader.h"

@interface R4ProgramManager () {
  NSMutableDictionary *vertexShaderCache;
  NSMutableDictionary *fragmentShaderCache;
  NSMutableDictionary *programCache;
}

@end

@implementation R4ProgramManager

static NSDictionary *buildTimeShaders = nil;
static R4ProgramManager *_programManagerInstance = nil;

+ (R4ProgramManager *)shared
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    buildTimeShaders = BUILD_TIME_SHADERS_MAP;
    _programManagerInstance = [[R4ProgramManager alloc] init];
  });
  return _programManagerInstance;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    vertexShaderCache = [NSMutableDictionary dictionary];
    fragmentShaderCache = [NSMutableDictionary dictionary];
    programCache = [NSMutableDictionary dictionary];
  }
  return self;
}

- (R4Shader *)loadShaderNamed:(NSString *)name type:(R4ShaderType)type attributeMapping:(NSDictionary *)attributeMapping
{
  R4Shader *shader = (type == R4ShaderTypeVertex) ? [vertexShaderCache objectForKey:name] : [fragmentShaderCache objectForKey:name];
  if (shader) { return shader; }
  
  // else Create load and compile shader
  NSString *source = [buildTimeShaders objectForKey:name];
  
  // try from file
  if (!source) {
    source = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil] encoding:NSUTF8StringEncoding error:nil];
  }
  
  if (type == R4ShaderTypeVertex) {
    shader = [[R4Shader alloc] initVertexShaderWithSourceString:source attributeMapping:attributeMapping];
    if (shader) [vertexShaderCache setObject:shader forKey:name];
  } else if (type == R4ShaderTypeFragment) {
    shader = [[R4Shader alloc] initFragmentShaderWithSourceString:source attributeMapping:attributeMapping];
    if (shader) [fragmentShaderCache setObject:shader forKey:name];
  }
  
  return shader;
}

- (R4Program *)programWithVertexShader:(R4Shader *)vertexShader fragmentShader:(R4Shader *)fragmentShader
{
  R4PairKey *key = [R4PairKey keyWithO1:vertexShader o2:fragmentShader];
  R4Program *program = [programCache objectForKey:key];

  if (!program) {
    program = [[R4Program alloc] initWithVertexShader:vertexShader fragmentShader:fragmentShader];
    [programCache setObject:program forKey:key];
  }

  return program;
}

- (R4Program *)programWithVertexShaderName:(NSString *)vertexShaderName fragmentShaderName:(NSString *)fragmentShaderName
{
  R4Shader *vertexShader = [vertexShaderCache objectForKey:vertexShaderName];
  R4Shader *fragmentShader = [fragmentShaderCache objectForKey:fragmentShaderName];
  
  NSAssert1(vertexShader, @"No vertex shader named [%@].", vertexShaderName);
  NSAssert1(fragmentShader, @"No fragment shader named [%@].", fragmentShaderName);
  
  return [self programWithVertexShader:vertexShader fragmentShader:fragmentShader];
}

@end
