//
//  R4ADSPass.m
//  R4
//
//  Created by Srđan Rašić on 09/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4ADSPass.h"
#import "R4NodePrivate.h"
#import "R4LightNode.h"
#import "R4Material.h"

@interface R4ADSPass () {
  NSArray *_defaultLights;
}

@end

@implementation R4ADSPass

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSDictionary *attribMap = @{@"in_position": @(R4VertexAttributePositionModelSpace),
                                @"in_texcoord": @(R4VertexAttributeTexCoord0),
                                @"in_normal": @(R4VertexAttributeNormalModelSpace)};
    
    _defaultLights = @[[R4LightNode pointLightAtPosition:GLKVector3Make(0, 100, 100)]];
    self.sceneBlend = R4BlendModeAlpha;
    self.depthTest = self.depthWrite = YES;
    self.cullFace = R4CullFaceBack;
    self.lighting = YES;
    self.vertexShader = [[R4ProgramManager shared] loadShaderNamed:@"vshADSShader" type:R4ShaderTypeVertex attributeMapping:attribMap];
    self.fragmentShader = [[R4ProgramManager shared] loadShaderNamed:@"fshADSShader" type:R4ShaderTypeFragment attributeMapping:nil];
    [self program];
  }
  return self;
}

- (void)prepareForDrawing:(R4DrawState *)drawState
{
  [super prepareForDrawing:drawState];
  
  R4Program *program = self.program;
  
  [program setUniformMatrix4fv:@"model_view_matrix" count:1 transpose:GL_FALSE v:drawState->modelViewMatrix.m];
  [program setUniformMatrix4fv:@"model_view_projection_matrix" count:1 transpose:GL_FALSE v:drawState->modelViewProjectionMatrix.m];
  [program setUniformMatrix3fv:@"normal_matrix" count:1 transpose:GL_FALSE v:drawState->normalMatrix.m];
  
  [program setUniform4fv:@"surface_ambient_color" count:1 v:drawState->material.ambientColor.v];
  [program setUniform4fv:@"surface_diffuse_color" count:1 v:drawState->material.diffuseColor.v];
  [program setUniform4fv:@"surface_specular_color" count:1 v:drawState->material.specularColor.v];
  [program setUniform1f:@"surface_shininess" v0:drawState->material.shininess];
  
  NSArray *lights = drawState->lightNodes;
  
  if (!lights.count) {
    lights = _defaultLights;
  }
  
  for (NSInteger idx = 0; idx < lights.count; idx++) {
    R4LightNode *light = [lights objectAtIndex:idx];
    
    [program setUniform4fv:[NSString stringWithFormat:@"lights[%d].ambient_color", idx] count:1 v:light.ambientColor.v];
    [program setUniform4fv:[NSString stringWithFormat:@"lights[%d].diffuse_color", idx] count:1 v:light.diffuseColor.v];
    [program setUniform4fv:[NSString stringWithFormat:@"lights[%d].specular_color", idx] count:1 v:light.specularColor.v];
    
    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4(drawState->viewMatrix, GLKVector4MakeWithVector3(light.positionWorldSpace, 1.0));
    [program setUniform4fv:[NSString stringWithFormat:@"lights[%d].position", idx] count:1 v:lightPosition.v];
  }
  
  [program setUniform1i:@"number_of_lights" v0:lights.count];
  
  if (self.firstTextureUnit.texture) {
    [program setUniform1f:@"texture_mask" v0:0.0f];
  } else {
    [program setUniform1f:@"texture_mask" v0:1.0f];
  }
}

@end
