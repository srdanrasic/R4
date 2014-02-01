//
//  R4Renderer.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Renderer.h"
#import "R4Shaders.h"
#import "R4NodePrivate.h"
#import "R4ScenePrivate.h"
#import "R4ViewPrivate.h"
#import "R4CameraNodePrivate.h"
#import "R4LightNodePrivate.h"
#import "R4EmitterNodePrivate.h"

#import "R4Program.h"
#import "R4Material.h"
#import "R4Technique.h"
#import "R4Pass.h"
#import "R4TextureUnit.h"
#import "R4Shader.h"

#import "R4EntityNode.h"
#import "R4Mesh.h"
#import "R4Texture.h"

@interface R4Renderer () {
  EAGLContext* _context;
  GLuint _defaultFramebuffer, _depthRenderbuffer, _colorRenderbuffer;
  GLint _backingWidth, _backingHeight;
  R4BlendMode _currentBlendMode;
  
  GLint lastBoundProgram_;
}

@property (nonatomic, strong) R4Material *particleMaterial;
@property (nonatomic, strong) R4Material *plainMaterial;

@end


@implementation R4Renderer

- (instancetype)init
{
  self = [super init];
  if (self) {
    if (![self initOpenGL]) return nil;
    _currentBlendMode = -1;
    lastBoundProgram_ = -1;
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
  
  if ([EAGLContext currentContext] == _context) {
    [EAGLContext setCurrentContext:nil];
  }
  
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
  
  // Get sorted drawables (TODO cache) -> move to SCENE MANAGER
  static NSMutableDictionary *entities = nil;
  static NSMutableArray *lights = nil;
  static NSMutableArray *emitters = nil;
  
  if (entities == nil) {
    entities = [NSMutableDictionary dictionary];
    lights = [NSMutableArray array];
    emitters = [NSMutableArray array];
    
    __block __unsafe_unretained void (^dfs)() = ^void(R4Node *root) {
      for (R4Node *node in root.children) {
        dfs(node);
        
        if ([node isKindOfClass:[R4EntityNode class]]) {
          R4EntityNode *entity = (R4EntityNode *)node;
          NSValue *key = [NSValue valueWithNonretainedObject:entity.mesh];
          NSMutableArray *array = [entities objectForKey:key];
          
          if (!array) {
            array = [NSMutableArray array];
            [entities setObject:array forKey:key];
          }
          
          [array addObject:entity];
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
  }
  
  // Render the scene
  GLKMatrix4 viewMatrix = [scene.currentCamera inversedTransform];
  GLKMatrix4 projectionMatrix = [scene.view projectionMatrix];

  for (NSValue *key in entities.allKeys) {
    R4Mesh *mesh = [key nonretainedObjectValue];
    glBindVertexArrayOES(mesh->vertexArray);
    
    for (R4EntityNode *entity in entities[key]) {
      R4Material *material = entity.material;
      R4Technique *technique = [material optimalTechnique];
      
      for (R4Pass *pass in technique.passes) {
        R4Program *program = pass.program;
        
        if (lastBoundProgram_ != program.programName) {
          glUseProgram(program.programName);
          lastBoundProgram_ = program.programName;
        }
        
        glFrontFace(pass.frontFace);
        
        if (pass.cullFace != R4CullFaceDisabled) {
          glEnable(GL_CULL_FACE);
          glCullFace(pass.cullFace);
        } else {
          glDisable(GL_CULL_FACE);
        }
        
        glDepthMask(pass.depthWrite);
        
        if (pass.depthTest) {
          glEnable(GL_DEPTH_TEST);
        } else {
          glDisable(GL_DEPTH_TEST);
        }
        
        setupBlendMode(pass.sceneBlend);
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, entity.modelViewMatrix);
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        
        [program setUniformMatrix4fv:@"model_view_projection_matrix" count:1 transpose:GL_FALSE v:modelViewProjectionMatrix.m];
        [program setUniform4fv:@"surface_diffuse_color" count:1 v:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f).v];
        [program setUniform1i:@"texture_sampler" v0:0];
        
        if (pass.firstTextureUnit.texture) {
          glActiveTexture(GL_TEXTURE0);
          glBindTexture(GL_TEXTURE_2D, pass.firstTextureUnit.texture.textureName);
          [program setUniform1f:@"texture_mask" v0:0.0f];
        } else {
          [program setUniform1f:@"texture_mask" v0:0.3f];
        }
        
        [entity drawPass];
      }
    }
  }

  // Render particle emitters
  for (R4EmitterNode *emitter in emitters) {
    R4Material *material = emitter.material;
    R4Technique *technique = [material optimalTechnique];
    
    [emitter prepareToDraw];
    
    for (R4Pass *pass in technique.passes) {
      R4Program *program = pass.program;
      
      if (lastBoundProgram_ != program.programName) {
        glUseProgram(program.programName);
        lastBoundProgram_ = program.programName;
      }
      
      glFrontFace(pass.frontFace);
      
      if (pass.cullFace != R4CullFaceDisabled) {
        glEnable(GL_CULL_FACE);
        glCullFace(pass.cullFace);
      } else {
        glDisable(GL_CULL_FACE);
      }
      
      glDepthMask(pass.depthWrite);
      
      if (pass.depthTest) {
        glEnable(GL_DEPTH_TEST);
      } else {
        glDisable(GL_DEPTH_TEST);
      }
      
      setupBlendMode(pass.sceneBlend);
      
      GLKMatrix4 mvpm = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
      [pass.program setUniformMatrix4fv:@"model_view_projection_matrix" count:1 transpose:GL_FALSE v:mvpm.m];
      [pass.program setUniform1i:@"texture_sampler" v0:0];
      
      glActiveTexture(GL_TEXTURE0);
      glBindTexture(GL_TEXTURE_2D, material.optimalTechnique.firstPass.firstTextureUnit.texture.textureName);
      
      [emitter drawPass];
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
