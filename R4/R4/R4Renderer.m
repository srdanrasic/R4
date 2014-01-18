//
//  R4Renderer.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Renderer.h"
#import "R4Shaders.h"
#import "R4Node_private.h"
#import "R4Scene_private.h"
#import "R4View_private.h"
#import "R4Camera_private.h"
#import "R4LightNode_Private.h"
#import "R4DrawableNode_private.h"
#import "R4DrawableObject.h"
#import "R4EmitterNode_Private.h"
#import "R4PrimitiveNode.h"
#import "R4GPUProgram.h"

#import "R4Program.h"
#import "R4Material.h"
#import "R4Technique.h"
#import "R4Pass.h"
#import "R4TextureUnit.h"

enum
{
  UNIFORM_MODELVIEWPROJECTION_MATRIX,
  UNIFORM_TEXTURE_SAMPLER,
  NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


@interface R4Renderer () {
  EAGLContext* _context;
  GLuint _defaultFramebuffer, _depthRenderbuffer, _colorRenderbuffer;
  GLint _backingWidth, _backingHeight;
  R4BlendMode _currentBlendMode;
}

@property (nonatomic, strong) R4Material *particleMaterial;

@end


@implementation R4Renderer

- (instancetype)init
{
  self = [super init];
  if (self) {
    if (![self initOpenGL]) return nil;
    _currentBlendMode = -1;
  }
  return self;
}

- (BOOL)initOpenGL
{
  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  if (!_context) return NO;
  
  [EAGLContext setCurrentContext:_context];
  
  glGenFramebuffers(1, &_defaultFramebuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
  
  glGenRenderbuffers(1, &_colorRenderbuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
  
  glGenRenderbuffers(1, &_depthRenderbuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
  
  glEnable(GL_DEPTH_TEST);
  
  R4Pass *pass = [[R4Pass alloc] initWithParticleShaders];
  R4Technique *technique = [[R4Technique alloc] initWithPasses:@[pass]];
  self.particleMaterial = [[R4Material alloc] initWithTechniques:@[technique]];
  
  return YES;
}


- (void)dealloc
{
  if (_defaultFramebuffer) {
    glDeleteFramebuffers(1, &_defaultFramebuffer);
    _defaultFramebuffer = 0;
  }
  
  if (_colorRenderbuffer) {
    glDeleteRenderbuffers(1, &_colorRenderbuffer);
    _colorRenderbuffer = 0;
  }
  
  if ([EAGLContext currentContext] == _context)
    [EAGLContext setCurrentContext:nil];
  
  _context = nil;
}

void setupBlendMode(R4BlendMode mode)
{
  if (mode == R4BlendModeAlpha) {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_FUNC_ADD);
  } else if (mode == R4BlendModeAdd) {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glBlendEquation(GL_FUNC_ADD);
  } else if (mode == R4BlendModeSubtract) {
    glBlendFunc(GL_SRC_ALPHA, GL_DST_ALPHA);
    glBlendEquation(GL_FUNC_SUBTRACT);
  } else if (mode == R4BlendModeMultiply) {
    glBlendFunc(GL_ZERO, GL_SRC_COLOR);
    glBlendEquation(GL_FUNC_ADD);
  } else if (mode == R4BlendModeMultiplyX2) {
    glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
    glBlendEquation(GL_FUNC_ADD);
  } else if (mode == R4BlendModeScreen) {
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE);
    glBlendEquation(GL_FUNC_ADD);
  } else if (mode == R4BlendModeReplace) {
    glBlendFunc(GL_ONE, GL_ZERO);
    glBlendEquation(GL_FUNC_ADD);
  }
}

- (void)render:(R4Scene *)scene
{
  [EAGLContext setCurrentContext:_context];
  
  glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
  
  //glEnable(GL_CULL_FACE);
  glDepthMask(GL_TRUE);
  
  glClearColor(0, 0, 0, 1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  CGFloat scale = scene.size.width / _backingWidth;
  
  if (scene.scaleMode == R4SceneScaleModeAspectFit && scale * _backingHeight < scene.size.height) {
    scale = scene.size.height / _backingHeight;
  } else if (scene.scaleMode == R4SceneScaleModeAspectFill && scale * _backingHeight > scene.size.height) {
    scale = scene.size.height / _backingHeight;
  }
  
  if (scene.scaleMode == R4SceneScaleModeAspectFill || scene.scaleMode == R4SceneScaleModeAspectFit) {
    glViewport((_backingWidth - scene.size.width / scale) / 2, (_backingHeight - scene.size.height / scale) / 2,
               scene.size.width / scale, scene.size.height / scale);
    
  } else {
    glViewport(0, 0, _backingWidth, _backingHeight);
  }
  
  glEnable(GL_SCISSOR_TEST);
  
  if (scene.scaleMode == R4SceneScaleModeAspectFit) {
    glScissor((_backingWidth - scene.size.width / scale) / 2, (_backingHeight - scene.size.height / scale) / 2,
              scene.size.width / scale, scene.size.height / scale);
  } else {
    glScissor(0, 0, _backingWidth, _backingHeight);
  }
  
  
  GLfloat r, g, b, a;
  [scene.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT);
  
  glEnable(GL_BLEND);
  setupBlendMode(R4BlendModeAlpha);
  
  // Get sorted drawables (TODO cache)
  NSMutableDictionary *drawables = [NSMutableDictionary dictionary];
  NSMutableArray *lights = [NSMutableArray array];
  NSMutableArray *emitters = [NSMutableArray array];
  __block __unsafe_unretained void (^dfs)() = ^void(R4Node *root) {
    for (R4Node *node in root.children) {
      dfs(node);
      
      if ([node isKindOfClass:[R4DrawableNode class]]) {
        R4DrawableNode *drawable = (R4DrawableNode *)node;
        NSValue *key = [NSValue valueWithNonretainedObject:drawable.drawableObject];
        NSMutableArray *array = [drawables objectForKey:key];
        
        if (!array) {
          array = [NSMutableArray array];
          [drawables setObject:array forKey:key];
        }
        
        [array addObject:drawable];
      } else if ([node isKindOfClass:[R4LightNode class]]) {
        [lights addObject:node];
      } else if ([node isKindOfClass:[R4EmitterNode class]]) {
        [emitters addObject:node];
      }
    }
  };
  dfs(scene);
  
  if (lights.count > 3) {
    @throw [NSException exceptionWithName:@"Error" reason:@"Scene is limited to 3 lights." userInfo:nil];
  }
  
  // Render the scene
  GLKMatrix4 cameraTransform = [scene.currentCamera inversedTransform];
  
  for (NSValue *key in drawables.allKeys) {
    R4DrawableObject *drawableObject = [key nonretainedObjectValue];
    GLKBaseEffect *effect = drawableObject.effect;
    BOOL hasElements = (drawableObject->indexBuffer != GL_INVALID_VALUE);
    
    effect.transform.projectionMatrix = [scene.view projectionMatrix];
    
    int lightNumber = 0;
    for (GLKEffectPropertyLight *effectProperty in @[effect.light0, effect.light1, effect.light2]) {
      if (lightNumber < lights.count) {
        R4LightNode *lightNode = [lights objectAtIndex:lightNumber++];
        effectProperty.enabled = GL_TRUE;
        effect.lightingType = GLKLightingTypePerPixel;
        effectProperty.ambientColor = lightNode.ambientColor;
        effectProperty.diffuseColor = lightNode.diffuseColor;
        effectProperty.specularColor = lightNode.specularColor;
        effectProperty.spotCutoff = lightNode.spotCutoff;
        effectProperty.spotExponent = lightNode.spotExponent;
        effectProperty.constantAttenuation = lightNode.constantAttenuation;
        effectProperty.linearAttenuation = lightNode.linearAttenuation;
        effectProperty.quadraticAttenuation = lightNode.quadraticAttenuation;
      } else {
        effectProperty.enabled = GL_FALSE;
      }
    }
    
    glBindVertexArrayOES(drawableObject->vertexArray);
    
    for (R4DrawableNode *drawable in drawables[key]) {
      GLKVector4 constantColor = effect.constantColor;
      
      effect.transform.modelviewMatrix = GLKMatrix4Multiply(cameraTransform, drawable.modelViewMatrix);
      
      int lightNumber = 0;
      for (GLKEffectPropertyLight *effectProperty in @[effect.light0, effect.light1, effect.light2]) {
        if (lightNumber < lights.count) {
          R4LightNode *lightNode = [lights objectAtIndex:lightNumber++];
          effectProperty.position = lightNode.homogeneousPosition;
          effectProperty.spotDirection = lightNode.spotDirection;
        }
      }
      
      if (drawable.highlightColor) {
        GLfloat r, g, b, a;
        [drawable.highlightColor getRed:&r green:&g blue:&b alpha:&a];
        effect.constantColor = GLKVector4Make(r, g, b, a);
      }
      
      [effect prepareToDraw];
      
      if (_currentBlendMode != drawable.blendMode) {
        setupBlendMode(drawable.blendMode);
        _currentBlendMode = drawable.blendMode;
      }
      
      if (hasElements) {
        glDrawElements(GL_TRIANGLES, drawableObject->elementCount, GL_UNSIGNED_SHORT, BUFFER_OFFSET(0));
      } else {
        glDrawArrays(GL_TRIANGLES, 0, drawableObject->elementCount);
      }
      
      effect.constantColor = constantColor;
    }
  }
  
  glDepthMask(GL_FALSE);
  
  for (R4EmitterNode *emitter in emitters) {
    
    R4Material *material = self.particleMaterial;
    R4Technique *technique = [material optimalTechnique];
    
    
    for (R4Pass *pass in technique.passes) {
      glUseProgram(pass.program.programName);
      
      setupBlendMode(emitter.particleBlendMode);
      
      glBindVertexArrayOES(emitter->particleAttributesVertexArray);
      glBindBuffer(GL_ARRAY_BUFFER, emitter->particleAttributesVertexBuffer);
      glBufferData(GL_ARRAY_BUFFER, emitter.particleCount * sizeof(R4ParticleAttributes), emitter.particleAttributes, GL_STREAM_DRAW);
      
      glActiveTexture(GL_TEXTURE0);
      glBindTexture(emitter.particleDrawable.drawableObject.effect.texture2d0.target, emitter.particleDrawable.drawableObject.effect.texture2d0.name);
      
      for (NSString *name in pass.program.autoUniforms) {
        NSInteger location = [[pass.program.autoUniforms objectForKey:name] integerValue];
        
        if ([name isEqualToString:@"model_view_projection_matrix"]) {
          GLKMatrix4 mvpm = GLKMatrix4Multiply(scene.view.projectionMatrix, cameraTransform);
          //mvpm = GLKMatrix4Multiply(mvpm, emitter.modelViewMatrix);
          glUniformMatrix4fv(location, 1, GL_FALSE, mvpm.m);
        } else if ([name isEqualToString:@"texture_sampler"]) {
          glUniform1i(location, 0);
        }
      }
      
      glDrawArraysInstancedEXT(GL_TRIANGLES, 0, 6, emitter.particleCount);
    }
  }
  
  const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
  glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
  
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  [_context presentRenderbuffer:GL_RENDERBUFFER];
  
  glDisable(GL_SCISSOR_TEST);
}

- (void)resizeFromLayer:(CAEAGLLayer *)layer
{
  layer.contentsScale = 2;
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
  
  glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
  
  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    @throw [NSException exceptionWithName:@"Failure"
                                   reason:[NSString stringWithFormat:@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER)]
                                 userInfo:nil];
  }
}

@end
