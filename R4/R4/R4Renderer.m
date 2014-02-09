//
//  R4Renderer.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Renderer.h"
#import "R4NodePrivate.h"
#import "R4ScenePrivate.h"
#import "R4ViewPrivate.h"
#import "R4CameraNodePrivate.h"
#import "R4Drawable.h"
#import "R4Program.h"
#import "R4Material.h"
#import "R4Technique.h"
#import "R4Pass.h"
#import "R4TextureUnit.h"
#import "R4DrawState.h"
#import "R4SceneManager.h"

@interface R4Renderer () {
  EAGLContext *eaglContext;
  
  GLuint defaultFramebuffer;
  GLuint defaultDepthRenderbuffer;
  GLuint defaultColorRenderbuffer;
  
  GLint backingWidth;
  GLint backingHeight;

  R4DrawState *drawState;
}

@end


@implementation R4Renderer

- (instancetype)init
{
  self = [super init];
  if (self) {
    eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!eaglContext) return nil;
    
    [EAGLContext setCurrentContext:eaglContext];
    
    glGenFramebuffers(1, &defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    glGenRenderbuffers(1, &defaultColorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, defaultColorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, defaultColorRenderbuffer);
    
    glGenRenderbuffers(1, &defaultDepthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, defaultDepthRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, defaultDepthRenderbuffer);
    
    drawState = [R4DrawState new];
    drawState->blendMode = -1;
    drawState->program = -1;
  }
  return self;
}

- (void)dealloc
{
  if (defaultFramebuffer) {
    glDeleteFramebuffers(1, &defaultFramebuffer);
    defaultFramebuffer = 0;
  }
  
  if (defaultColorRenderbuffer) {
    glDeleteRenderbuffers(1, &defaultColorRenderbuffer);
    defaultColorRenderbuffer = 0;
  }
  
  if ([EAGLContext currentContext] == eaglContext) {
    [EAGLContext setCurrentContext:nil];
  }
  
  eaglContext = nil;
}

- (void)render:(R4Scene *)scene
{
  // Setup context, default framebuffer and clear
  [EAGLContext setCurrentContext:eaglContext];
  
  glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
  
  glDepthMask(GL_TRUE);
  
  glClearColor(0, 0, 0, 1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // Setup viewport
  CGFloat scale = scene.size.width / backingWidth;
  
  if (scene.scaleMode == R4SceneScaleModeAspectFit && scale * backingHeight < scene.size.height) {
    scale = scene.size.height / backingHeight;
  } else if (scene.scaleMode == R4SceneScaleModeAspectFill && scale * backingHeight > scene.size.height) {
    scale = scene.size.height / backingHeight;
  }
  
  if (scene.scaleMode == R4SceneScaleModeAspectFill || scene.scaleMode == R4SceneScaleModeAspectFit) {
    glViewport((backingWidth - scene.size.width / scale) / 2, (backingHeight - scene.size.height / scale) / 2,
               scene.size.width / scale, scene.size.height / scale);
    
  } else {
    glViewport(0, 0, backingWidth, backingHeight);
  }
  
  glEnable(GL_SCISSOR_TEST);
  
  if (scene.scaleMode == R4SceneScaleModeAspectFit) {
    glScissor((backingWidth - scene.size.width / scale) / 2, (backingHeight - scene.size.height / scale) / 2,
              scene.size.width / scale, scene.size.height / scale);
  } else {
    glScissor(0, 0, backingWidth, backingHeight);
  }
  
  GLfloat r, g, b, a;
  [scene.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT);
  
  glEnable(GL_BLEND);
  setupBlendMode(R4BlendModeAlpha);
  
  // Render the scene
  drawState->viewMatrix = [scene.currentCamera inversedTransform];
  drawState->projectionMatrix  = [scene.view projectionMatrix];
  drawState->viewProjectionMatrix = GLKMatrix4Multiply(drawState->projectionMatrix, drawState->viewMatrix);

  [scene.sceneManager enumerateDrawableNodesWithBlock:^(R4Node<R4Drawable> *node) {
    R4Material *material = node.material;
    R4Technique *technique = [material optimalTechnique];
    
    drawState->material = material;
    
    [node prepareToDraw];
       
    for (R4Pass *pass in technique.passes) {
      drawState->modelMatrix = node.modelMatrix;
      drawState->modelViewMatrix = GLKMatrix4Multiply(drawState->viewMatrix, drawState->modelMatrix);
      drawState->modelViewProjectionMatrix = GLKMatrix4Multiply(drawState->projectionMatrix, drawState->modelViewMatrix);
      drawState->normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(drawState->modelViewMatrix, NULL));
      
      if (pass.lighting) {
        drawState->lightNodes = [scene.sceneManager lightsFromNode:node];
      } else {
        drawState->lightNodes = nil;
      }
      
      [pass prepareForDrawing:drawState];
      
      NSUInteger numberOfIterations = (pass.iteratePerLight) ? numberOfIterations = drawState->lightNodes.count : pass.numberOfIterations;

      for (NSInteger iteration = 0; iteration < numberOfIterations; iteration++) {
        [pass prepareForIteration:iteration drawState:drawState];
        [node draw];
      }
    }
  }];
  
  // Clean up
  const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
  glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
  
  glBindRenderbuffer(GL_RENDERBUFFER, defaultColorRenderbuffer);
  [eaglContext presentRenderbuffer:GL_RENDERBUFFER];
  
  glDisable(GL_SCISSOR_TEST);
}

- (void)resizeFromLayer:(CAEAGLLayer *)layer
{
  layer.contentsScale = 2;
  glBindRenderbuffer(GL_RENDERBUFFER, defaultColorRenderbuffer);
  [eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
  
  glBindRenderbuffer(GL_RENDERBUFFER, defaultDepthRenderbuffer);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
  
  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    @throw [NSException exceptionWithName:@"Failure"
                                   reason:[NSString stringWithFormat:@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER)]
                                 userInfo:nil];
  }
}

@end
