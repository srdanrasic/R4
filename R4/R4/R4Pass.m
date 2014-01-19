//
//  R4Pass.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Pass.h"
#import "R4Shader.h"
#import "R4Shaders.h"
#import "R4Program.h"

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
    self.textureUnits = [NSMutableArray array];
  }
  return self;
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
    R4Program *program = [[R4Program alloc] initWithVertexShader:self.vertexShader fragmentShader:self.fragmentShader];
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

- (void)prepareToDraw
{
}

@end
