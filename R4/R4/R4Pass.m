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

- (instancetype)initWithParticleShaders
{
  self = [super init];
  if (self) {
    self.sceneBlend = R4BlendModeAlpha;
    self.lighting = YES;
    self.depthTest = YES;
    self.depthWrite = NO;
    self.textureUnits = nil;
    
    NSDictionary *vshMapping = @{ @"position": @(R4VertexAttributePosition),
                                  @"texcoord": @(R4VertexAttributeTexCoord0),
                                  @"instanceColor": @(R4VertexAttributeColor),
                                  @"instanceColorBlendFactor": @(R4VertexAttributeColorBlendFactor),
                                  @"instanceMVM": @(R4VertexAttributeMVM)
                                  };
    
    self.vertexShader = [[R4Shader alloc] initVertexShaderWithSourceString:[NSString stringWithCString:vshParticleShaderSourceString encoding:NSUTF8StringEncoding] attributeMapping:vshMapping];
    self.fragmentShader = [[R4Shader alloc] initFragmentShaderWithSourceString:[NSString stringWithCString:fshParticleShaderSourceString encoding:NSUTF8StringEncoding] attributeMapping:nil];
    
    [self program];
  }
  return self;
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

@end
