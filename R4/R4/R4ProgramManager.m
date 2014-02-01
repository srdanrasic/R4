//
//  R4ProgramManager.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4ProgramManager.h"
#import "R4Program.h"
#import "R4Shader.h"
#import "R4Shaders.h"

@interface R4PairKey : NSObject  <NSCopying> {
  __weak id _o1;
  __weak id _o2;
}

+ (R4PairKey *)keyWithO1:(id)o1 o2:(id)o2;

@end

@implementation R4PairKey

+ (R4PairKey *)keyWithO1:(id)o1 o2:(id)o2
{
  R4PairKey *key = [[[self class] alloc] init];
  key->_o1 = o1;
  key->_o2 = o2;
  return key;
}

- (BOOL)isEqual:(id)object
{
  if (!self || !object) {
    return NO;
  } else if (self == object) {
    return YES;
  } else if ([object isKindOfClass:[self class]]) {
    R4PairKey *other = (R4PairKey *)object;
    return ((_o1 || _o2) && _o1 == other->_o1 && _o2 == other->_o2);
  } else {
    return NO;
  }
}

- (id)copyWithZone:(NSZone *)zone
{
  R4PairKey *key = [[[self class] alloc] init];
  key->_o1 = _o1;
  key->_o2 = _o2;
  return key;
}

@end


@interface R4ProgramManager () {
  NSMutableDictionary *vertexShaderCache;
  NSMutableDictionary *fragmentShaderCache;
  NSMutableDictionary *programCache;
}

@end

@implementation R4ProgramManager

NSDictionary *buildTimeShaders = nil;
R4ProgramManager *_programManagerInstance = nil;

+ (R4ProgramManager *)shared
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _programManagerInstance = [[R4ProgramManager alloc] init];
  });
  return _programManagerInstance;
}
 
+ (void)initialize
{
  buildTimeShaders = BUILD_TIME_SHADERS_MAP;
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

- (R4Shader *)loadVertexShaderNamed:(NSString *)name attributeMapping:(NSDictionary *)attributeMapping
{
  R4Shader *shader = [vertexShaderCache objectForKey:name];
  
  // if already loaded
  if (shader) {
    return shader;
  }
  
  NSString *source = [buildTimeShaders objectForKey:name];
  
  if (!source) {
    source = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil] encoding:NSUTF8StringEncoding error:nil];
  }
  
  shader = [[R4Shader alloc] initVertexShaderWithSourceString:source attributeMapping:attributeMapping];
  if (shader) [vertexShaderCache setObject:shader forKey:name];
  
  return shader;
}

- (R4Shader *)loadFragmentShaderNamed:(NSString *)name attributeMapping:(NSDictionary *)attributeMapping
{
  R4Shader *shader = [fragmentShaderCache objectForKey:name];
  
  // if already loaded
  if (shader) {
    return shader;
  }
  
  NSString *source = [buildTimeShaders objectForKey:name];
  
  if (!source) {
    source = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil] encoding:NSUTF8StringEncoding error:nil];
  }
  
  shader = [[R4Shader alloc] initFragmentShaderWithSourceString:source attributeMapping:attributeMapping];
  if (shader) [fragmentShaderCache setObject:shader forKey:name];
  
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
