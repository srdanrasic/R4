//
//  R4ParticlePass.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4ParticlePass.h"
#import "R4Texture.h"
#import "R4TextureUnit.h"
#import "R4ProgramManager.h"

@implementation R4ParticlePass

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.lighting = NO;
    self.depthTest = YES;
    self.depthWrite = NO;
    self.cullFace = R4CullFaceDisabled;
        
    NSDictionary *vshMapping = @{ @"position_modelspace": @(R4VertexAttributePositionModelSpace),
                                  @"texcoord": @(R4VertexAttributeTexCoord0),
                                  @"instanceColor": @(R4VertexAttributeColor),
                                  @"instanceColorBlendFactor": @(R4VertexAttributeColorBlendFactor),
                                  @"instanceModelMatrix": @(R4VertexAttributeModelMatrix)
                                  };
    
    self.vertexShader = [[R4ProgramManager shared] loadShaderNamed:@"vshParticleShader" type:R4ShaderTypeVertex attributeMapping:vshMapping];
    self.fragmentShader = [[R4ProgramManager shared] loadShaderNamed:@"fshParticleShader"  type:R4ShaderTypeFragment attributeMapping:nil];
    [self program];
  }
  return self;
}

- (void)prepareForDrawing:(R4DrawState *)drawState
{
  [super prepareForDrawing:drawState];
  
  if (_relativeParticlePosition) {
    [self.program setUniformMatrix4fv:@"view_projection_matrix" count:1 transpose:GL_FALSE v:drawState->modelViewProjectionMatrix.m];
  } else {
    [self.program setUniformMatrix4fv:@"view_projection_matrix" count:1 transpose:GL_FALSE v:drawState->viewProjectionMatrix.m];
  }
  
  [self.program setUniform1i:@"texture_sampler" v0:0];  
}

@end
