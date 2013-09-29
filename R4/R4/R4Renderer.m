//
//  R4Renderer.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Renderer.h"
#import "R4Scene_Private.h"

@interface R4Renderer () {
  EAGLContext* _context;
  GLuint _defaultFramebuffer, _colorRenderbuffer;
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
  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
  if (!_context) return NO;
  
  [EAGLContext setCurrentContext:_context];
  
  glGenFramebuffers(1, &_defaultFramebuffer);
  glGenRenderbuffers(1, &_colorRenderbuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
  
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
  glViewport(0, 0, _backingWidth, _backingHeight);
  
  GLfloat r, g, b, a;
  [scene.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT);
  
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resizeFromLayer:(CAEAGLLayer *)layer
{
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
  
  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    @throw [NSException exceptionWithName:@"Failure"
                                   reason:[NSString stringWithFormat:@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER)]
                                 userInfo:nil];
  }
}

@end
