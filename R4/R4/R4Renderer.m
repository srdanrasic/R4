//
//  R4Renderer.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Renderer.h"
#import "R4Node_private.h"
#import "R4Scene_private.h"
#import "R4View_private.h"
#import "R4Camera_private.h"
#import "R4DrawableNode_private.h"
#import "R4DrawableObject.h"

@interface R4Renderer () {
  EAGLContext* _context;
  GLuint _defaultFramebuffer, _depthRenderbuffer, _colorRenderbuffer;
  GLint _backingWidth, _backingHeight;
}

@end


@implementation R4Renderer

- (instancetype)init
{
  self = [super init];
  if (self) {
    if (![self initOpenGL]) return nil;
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
  
  if ([EAGLContext currentContext] == _context)
    [EAGLContext setCurrentContext:nil];
  
  _context = nil;
}

- (void)render:(R4Scene *)scene
{
  [EAGLContext setCurrentContext:_context];
  
  glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
  
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
  
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  
  GLfloat r, g, b, a;
  [scene.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT);
  
  // Render the scene
  GLKMatrix4 cameraTransform = [scene.currentCamera inversedTransform];
  
  __block __unsafe_unretained void (^dfs)() = ^void(R4Node *root) {
    for (R4Node *node in root.children) {
      dfs(node);
      
      if ([node isKindOfClass:[R4DrawableNode class]]) {
        R4DrawableNode *drawable = (R4DrawableNode *)node;
        
        drawable.drawableObject.effect.transform.projectionMatrix = [scene.view projectionMatrix];
        drawable.drawableObject.effect.transform.modelviewMatrix = GLKMatrix4Multiply(cameraTransform, node.modelViewMatrix);
        drawable.drawableObject.effect.light0.position = GLKVector4Make(0, 0, -1, 0);
        [drawable.drawableObject.effect prepareToDraw];
        [drawable draw];
      }
    }
  };
  dfs(scene);
  
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  [_context presentRenderbuffer:GL_RENDERBUFFER];
  
  glDisable(GL_SCISSOR_TEST);
}

- (void)resizeFromLayer:(CAEAGLLayer *)layer
{
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
