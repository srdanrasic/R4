//
//  R4BasicPass.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4BasicPass.h"
#import "R4ProgramManager.h"
#import "R4Material.h"

@implementation R4BasicPass

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSDictionary *attribMap = @{@"in_position": @(R4VertexAttributePositionModelSpace),
                                @"in_texcoord": @(R4VertexAttributeTexCoord0)};
    
    self.sceneBlend = R4BlendModeAlpha;
    self.depthTest = self.depthWrite = YES;
    self.cullFace = R4CullFaceBack;
    self.vertexShader = [[R4ProgramManager shared] loadShaderNamed:@"vshBasicShader" type:R4ShaderTypeVertex attributeMapping:attribMap];
    self.fragmentShader = [[R4ProgramManager shared] loadShaderNamed:@"fshBasicShader" type:R4ShaderTypeFragment attributeMapping:nil];
    [self program];
  }
  return self;
}

- (void)prepareForDrawing:(R4DrawState *)drawState
{
  [super prepareForDrawing:drawState];
  
  R4Program *program = self.program;
  
  [program setUniformMatrix4fv:@"model_view_projection_matrix" count:1 transpose:GL_FALSE v:drawState->modelViewProjectionMatrix.m];
  [program setUniform4fv:@"surface_diffuse_color" count:1 v:drawState->material.diffuseColor.v];
  [program setUniform1i:@"texture_sampler" v0:0];
  
  if (self.firstTextureUnit.texture) {
    [program setUniform1f:@"texture_mask" v0:0.0f];
  } else {
    [program setUniform1f:@"texture_mask" v0:1.0f];
  }
}

@end
