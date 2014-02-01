//
//  R4Pass.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Pass.h"
#import "R4Shader.h"
#import "R4Program.h"
#import "R4ProgramManager.h"

@interface R4Pass () {
  BOOL _isProgramDirty;
  R4Program *_program;
}

@end

@implementation R4Pass

- (instancetype)init
{
  self = [super init];
  if (self) {
    // init default pass
    self.frontFace = R4FrontFaceCCW;
    self.cullFace = R4CullFaceDisabled;
    self.textureUnits = [NSMutableArray array];
  }
  return self;
}

+ (instancetype)pass
{
  return [[[self class] alloc] init];
}

- (void)dealloc
{
  NSLog(@"Deleting pass.");
}

- (void)setVertexShader:(R4Shader *)vertexShader
{
  _vertexShader = vertexShader;
  _isProgramDirty = YES;
}

- (void)setFragmentShader:(R4Shader *)fragmentShader
{
  _fragmentShader = fragmentShader;
  _isProgramDirty = YES;
}

- (R4Program *)program
{
  if (_isProgramDirty) {
    R4Program *program = [[R4ProgramManager shared] programWithVertexShader:self.vertexShader fragmentShader:self.fragmentShader];
    if (program) {
      _program = program;
      _isProgramDirty = NO;
      return _program;
    } else {
      return nil;
    }
  } else {
    return _program;
  }
}

- (void)addTextureUnit:(R4TextureUnit *)textureUnit
{
  [self.textureUnits addObject:textureUnit];
}

- (R4TextureUnit *)firstTextureUnit
{
  return [self.textureUnits firstObject];
}

- (R4TextureUnit *)textureUnitAtIndex:(NSUInteger)index
{
  return [self.textureUnits objectAtIndex:index];
}

- (void)prepareToDraw:(R4DrawState *)drawState
{
  R4Program *program = self.program; // use property!
  
  if (drawState->program != program.programName) {
    glUseProgram(program.programName);
    drawState->program = program.programName;
  }
  
  glFrontFace(_frontFace);
  
  if (_cullFace != R4CullFaceDisabled) {
    glEnable(GL_CULL_FACE);
    glCullFace(_cullFace);
  } else {
    glDisable(GL_CULL_FACE);
  }
  
  glDepthMask(_depthWrite);
  
  if (_depthTest) {
    glEnable(GL_DEPTH_TEST);
  } else {
    glDisable(GL_DEPTH_TEST);
  }
  
  setupBlendMode(_sceneBlend);
  
  for (NSInteger idx = 0; idx < _textureUnits.count; idx++) {
    glActiveTexture(GL_TEXTURE0 + idx);
    glBindTexture(GL_TEXTURE_2D, [self textureUnitAtIndex:idx].texture.textureName);
  }
}

@end
