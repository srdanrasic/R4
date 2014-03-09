//
//  R4View.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Renderer.h"
#import "R4ViewPrivate.h"
#import "R4ScenePrivate.h"
#import "R4CameraNodePrivate.h"
#import "R4NodePrivate.h"

@interface R4View ()
@property (nonatomic, strong, readwrite) R4Scene *scene;
@property (nonatomic, strong) R4Renderer *rendered;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval timeOfLastUpdate;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, weak) R4Node *firstResponder;
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
  
  self.responderChain = [NSMutableArray arrayWithCapacity:15];
  
  self.rendered = [R4Renderer new];
  if (!self.rendered) @throw [NSException exceptionWithName:@"Failure" reason:@"Unable to initialize OpenGL" userInfo:nil];
}

- (void)initProperties
{
  self.frameInterval = 1;
  self.userInteractionEnabled = YES;
}

- (void)drawView:(id)sender
{
  NSTimeInterval currentTime = CACurrentMediaTime();
  NSTimeInterval elapsedTime = currentTime - self.timeOfLastUpdate;
  self.frameCount++;
  
  if (elapsedTime > 1.0) {
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d", self.frameCount];
    self.timeOfLastUpdate = currentTime;
    self.frameCount = 0;
  }
  
  if (!self.isPaused) {
    [self.scene update:currentTime];
    
    // evaluate actions
    [self.scene updateNodeAtTime:currentTime];
    [self.scene didEvaluateActions];
    
    // simulate particles
    [self.scene updateParticleEmittersAtTime:currentTime];
    
    // simulate physics
    [self.scene didSimulatePhysics];
  }

  [self.rendered render:self.scene];
}

- (void)layoutSubviews
{
  if (self.scene.scaleMode == R4SceneScaleModeResizeFill) {
    self.scene.size = self.frame.size;
  }
  
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

- (void)setShowFPS:(BOOL)showFPS
{
  _showFPS = showFPS;
  
  if (showFPS) {
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 80, 10, 70, 30)];
    self.fpsLabel.font = [UIFont systemFontOfSize:20];
    self.fpsLabel.textColor = [UIColor whiteColor];
    self.fpsLabel.textAlignment = NSTextAlignmentRight;
    self.fpsLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:self.fpsLabel];
  } else {
    [self.fpsLabel removeFromSuperview];
    self.fpsLabel = nil;
  }
}

- (void)setPaused:(BOOL)paused
{
  _paused = paused;
  [self.scene setPaused:paused];
}

- (void)presentScene:(R4Scene *)scene
{
  self.scene = scene;
  self.scene.view = self;

  if (scene.scaleMode == R4SceneScaleModeResizeFill) {
    self.scene.size = self.frame.size;
  }

  [self.scene didMoveToView:self];
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

- (GLKMatrix4)projectionMatrix
{
  float aspect = fabsf(self.scene.size.width / self.scene.size.height);
  return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 1000.0f);
}

- (CGPoint)convertPoint:(GLKVector3)point fromScene:(R4Scene *)scene
{
  GLint viewport[4] = {};
  glGetIntegerv(GL_VIEWPORT, viewport);
  for (int i = 0; i < 4; i++) { viewport[i] /= [UIScreen mainScreen].scale; }
  GLKVector3 result = GLKMathProject(point, self.scene.currentCamera.inversedTransform, self.scene.view.projectionMatrix, viewport);
  
  return CGPointMake(result.x, result.y);
}

- (R4Ray)convertPoint:(CGPoint)point toScene:(R4Scene *)scene
{
  bool success = NO;
  GLint viewport[4] = {};
  glGetIntegerv(GL_VIEWPORT, viewport);
  for (int i = 0; i < 4; i++) { viewport[i] /= [UIScreen mainScreen].scale; }
  
  GLKVector3 originInWindowNear = GLKVector3Make(point.x, viewport[3] - point.y, 0.0f);
  GLKVector3 resultNear = GLKMathUnproject(originInWindowNear, self.scene.currentCamera.inversedTransform, self.scene.view.projectionMatrix, viewport, &success);
  
  GLKVector3 originInWindowFar = GLKVector3Make(point.x, viewport[3] - point.y, 1.0f);
  GLKVector3 resultFar = GLKMathUnproject(originInWindowFar, self.scene.currentCamera.inversedTransform, self.scene.view.projectionMatrix, viewport, &success);

  GLKVector3 direction = GLKVector3Subtract(resultFar, resultNear);
  R4Ray ray = R4RayMake(resultNear, direction);
  return ray;
}

#pragma mark - UIResponder overrides

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  [self.responderChain removeAllObjects];
  
  if (self.scene.userInteractionEnabled && [self pointInside:point withEvent:event]) {
    R4Ray ray = [self convertPoint:point toScene:self.scene];
    self.firstResponder = [self.scene hitTest:ray event:event];
    
    [self.responderChain sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      R4Node *n1 = (R4Node *)obj1;
      R4Node *n2 = (R4Node *)obj2;
      return n1->_distanceToCamera < n2->_distanceToCamera;
    }];
    
    if (self.firstResponder) {
      //NSLog(@"First responder: %@", self.firstResponder);
      return self;
    }
  }
  
  for (UIView *view in self.subviews) {
    if ([view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
      UIView *hitTestView = [view hitTest:[self convertPoint:point toView:view] withEvent:event];
      if (hitTestView) {
        return hitTestView;
      }
    }
  }
  
  return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.firstResponder) {
    [self.firstResponder touchesBegan:touches withEvent:event];
  } else {
    [super touchesBegan:touches withEvent:event];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.firstResponder) {
    [self.firstResponder touchesMoved:touches withEvent:event];
  } else {
    [super touchesMoved:touches withEvent:event];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.firstResponder) {
    [self.firstResponder touchesEnded:touches withEvent:event];
  } else {
    [super touchesEnded:touches withEvent:event];
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.firstResponder) {
    [self.firstResponder touchesCancelled:touches withEvent:event];
  } else {
    [super touchesCancelled:touches withEvent:event];
  }
}

@end
