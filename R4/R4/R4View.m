//
//  R4View.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4View_Private.h"
#import "R4Scene_Private.h"
#import "R4Renderer.h"

@interface R4View ()
@property (nonatomic, strong, readwrite) R4Scene *scene;
@property (nonatomic, strong) R4Renderer *rendered;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation R4View

+ (Class)layerClass
{
  return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit
{
  [self initProperties];
  
  CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
  
  layer.opaque = YES;
  layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO), kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
  
  self.rendered = [R4Renderer new];
  if (!self.rendered) @throw [NSException exceptionWithName:@"Failure" reason:@"Unable to initialize OpenGL" userInfo:nil];
}

- (void)initProperties
{
  self.frameInterval = 1;
  self.userInteractionEnabled = YES;
  self.ignoresSiblingOrder = NO;
}

- (void)drawView:(id)sender
{
  [self.rendered render:self.scene];
}

- (void)layoutSubviews
{
  [self.rendered resizeFromLayer:(CAEAGLLayer *)self.layer];
  [self drawView:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
  if (newSuperview == nil) {
    [self.displayLink invalidate];
    self.displayLink = nil;
  }
}

- (void)didMoveToSuperview
{
  [self.displayLink invalidate];
  if (self.superview) {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    [self.displayLink setFrameInterval:self.frameInterval];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  }
}

#pragma mark - Instance methods

- (void)presentScene:(R4Scene *)scene
{
  self.scene = scene;
  self.scene.view = self;
}

- (void)presentScene:(R4Scene *)scene transition:(R4Transition *)transition
{
  if (!self.scene) {
    [self presentScene:scene];
  } else {
    // TODO
  }
}

- (R4Texture *)textureFromNode:(R4Node *)node
{
  // TODO
  return nil;
}

- (CGPoint)convertPoint:(CGPoint)point fromScene:(R4Scene *)scene
{
  point.y = self.frame.size.height - (scene.anchorPoint.y * self.frame.size.height + point.y);
  point.x = scene.anchorPoint.x * self.frame.size.width + point.x;
  return point;
}

- (CGPoint)convertPoint:(CGPoint)point toScene:(R4Scene *)scene
{
  // TODO
  return CGPointMake(0, 0);
}

- (GLKMatrix4)projectionMatrix
{
  float aspect = fabsf(self.bounds.size.width / self.bounds.size.height);
  return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
}

@end
