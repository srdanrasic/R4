//
//  R4ViewController.m
//  R4 iOS Demo
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4ViewController.h"
#import <R4/R4View.h>
#import <R4/R4Scene.h>
#import <R4/R4Action.h>
#import <R4/R4Camera.h>
#import <R4/R4LightNode.h>
#import <R4/R4EmitterNode.h>
#import <R4/R4Camera_private.h>
#import <R4/R4Scene_private.h>
#import <R4/R4View_private.h>
#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioServices.h>

#import <R4/R4EntityNode.h>
#import <R4/R4Mesh.h>


@interface Stacy : R4EntityNode
@end

@implementation Stacy

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"Stacy touchesBegin");
  //self.highlightColor = [UIColor redColor];
  AudioServicesPlaySystemSound (1104);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  R4Ray ray = [self.scene.view convertPoint:[[touches anyObject] locationInView:self.scene.view] toScene:self.scene];
  GLfloat d = GLKVector3DotProduct(GLKVector3Negate(ray.startPoint), GLKVector3Make(0, 1, 0)) / GLKVector3DotProduct(ray.direction, GLKVector3Make(0, 1, 0));
  GLKVector3 point = GLKVector3Add(ray.startPoint, GLKVector3MultiplyScalar(ray.direction, d));
  NSLog(@"TM: %@", NSStringFromGLKVector3(point));
  [self setPosition:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  //self.highlightColor = nil;
}

@end


@interface Sparks : R4EmitterNode
@end

@implementation Sparks

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"Emitter touchesBegin");
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"Sparks touchesMoved");
  R4Ray ray = [self.scene.view convertPoint:[[touches anyObject] locationInView:self.scene.view] toScene:self.scene];
  GLfloat d = GLKVector3DotProduct(GLKVector3Negate(ray.startPoint), GLKVector3Make(0, 1, 0)) / GLKVector3DotProduct(ray.direction, GLKVector3Make(0, 1, 0));
  GLKVector3 point = GLKVector3Add(ray.startPoint, GLKVector3MultiplyScalar(ray.direction, d));

  [self setPosition:point];
}

@end

@interface MyScene : R4Scene
@property (assign, nonatomic) NSTimeInterval timeOfLastUpdate;
@end

@implementation MyScene


- (void)didMoveToView:(R4View *)view
{
  self.userInteractionEnabled = YES;
  self.name = @"mainScene";
  
  R4Node *stacyBase = [R4Node node];
  stacyBase.name = @"stacyBase";
  stacyBase.userInteractionEnabled = YES;

  [self addChild:stacyBase];
  
  R4EntityNode *stacy = [R4EntityNode entityWithMesh:[R4Mesh OBJMeshNamed:@"stacy.obj" normalize:YES center:NO]];
  stacy.name = @"stacy";
  stacy.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, -1);
  stacy.scale = GLKVector3Make(1, 1, 1);
  stacy.speed = 1;
  //stacy.blendMode = R4BlendModeAlpha;
  stacy.userInteractionEnabled = YES;
  [stacyBase addChild:stacy];

#if 0
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      R4Node *c2 = [stacy copy];
      c2.position = GLKVector3Make(-2 + i, 0, 1-j);
      CGFloat duration = 0.5 + (arc4random() % 100) / 50.0;
      [c2 runAction:[R4Action repeatActionForever:[R4Action sequence:@[
                                                                       [R4Action scaleTo:GLKVector3Make(1, 1, 1) duration:duration],
                                                                       [R4Action scaleTo:GLKVector3Make(1, .5, 1) duration:duration]
                                                                       ]]]];
      [self addChild:c2];
    }
  }
#endif
  
  [stacy removeAllActions];
  stacy.position = GLKVector3Make(0, 0, 4);

  R4EntityNode *base = [R4EntityNode entityWithMesh:[R4Mesh boxWithSize:GLKVector3Make(15, .01, 15)]];
  base.name = @"base";
  base.userInteractionEnabled = YES;
  base.position = GLKVector3Make(0, 0, 0);
  ///spaceship2.orientation = GLKQuaternionMakeWithAngleAndAxis(0.6, 0, 1, -1);
  //base.highlightColor = [UIColor colorWithRed:0.1 green:0.05 blue:0.1 alpha:1.0];
  [self addChild:base];
  
#if 1
  R4LightNode *light = [R4LightNode pointLightAtPosition:GLKVector3Make(0, 2, 2)];
  light.constantAttenuation = 0;
  light.linearAttenuation = 1;
  [self addChild:light];
#endif
  
  self.currentCamera.position = GLKVector3Make(-1, 10, 1);
  //self.currentCamera.targetNode = stacy;
  self.currentCamera.name = @"Camera";
  //[stacy addChild:self.currentCamera];
  
  R4EmitterNode *fire = [[Sparks alloc] initWithSKEmitterSKSFileNamed:@"FireParticle"];
  fire.position = GLKVector3Make(1, 0, 0);
  fire.userInteractionEnabled = YES;
  [self addChild:fire];
  
  R4EmitterNode *sparks = [[Sparks alloc] initWithSKEmitterSKSFileNamed:@"SparkParticle"];
  sparks.position = GLKVector3Make(-1, 0, 0);
  sparks.userInteractionEnabled = YES;
  sparks.name = @"sparks";
  [self addChild:sparks];
  
  R4EntityNode *mp = [R4EntityNode entityWithMesh:[R4Mesh boxWithSize:GLKVector3Make(1, 5, 1)]];
  mp.userInteractionEnabled = YES;
  [self addChild:mp];
  
  R4EmitterNode *smoke = [[R4EmitterNode alloc] initWithSKEmitterSKSFileNamed:@"SnowParticle"];
  smoke.position = GLKVector3Make(0, 4, 0);
  smoke.particlePositionRange = GLKVector3Make(10, 0, 10);
  smoke.name = @"smoke";
  [self addChild:smoke];
  self.timeOfLastUpdate = CACurrentMediaTime();
}

- (void)update:(NSTimeInterval)currentTime
{
  NSTimeInterval elapsedTime = currentTime - self.timeOfLastUpdate;
  
  [self childNodeWithName:@"stacyBase"].orientation = GLKQuaternionMultiply([self childNodeWithName:@"stacyBase"].orientation, GLKQuaternionMakeWithAngleAndAxis(elapsedTime/2.0, 0, 1, 0));
  //[self childNodeWithName:@"base"].orientation = GLKQuaternionMultiply([self childNodeWithName:@"base"].orientation, GLKQuaternionMakeWithAngleAndAxis(2*elapsedTime, 0, 1, 0));
  
  //self.currentCamera.position = GLKVector3Make(-sinf(currentTime) * 3, 2, cosf(currentTime) * 3);

  self.timeOfLastUpdate = currentTime;
  //NSLog(@"FPS: %f", 1.0/elapsedTime);
}

@end


@interface R4ViewController ()
@property (nonatomic, strong) R4View *r4view;
@property (nonatomic, strong) MyScene *scene;
@end

@implementation R4ViewController

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
	self.r4view = [[R4View alloc] initWithFrame:self.view.bounds];
  self.r4view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.r4view.showFPS = YES;
  [self.view addSubview:self.r4view];
  
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width * scale, [UIScreen mainScreen].bounds.size.height * scale);
  self.scene = [MyScene sceneWithSize:size];
  self.scene.scaleMode = R4SceneScaleModeResizeFill;
  [self.r4view presentScene:self.scene];
  
  UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  pauseButton.frame = CGRectMake(10, 10, 120, 30);
  [pauseButton setTitle:@"Pause scene" forState:UIControlStateNormal];
  [pauseButton addTarget:self action:@selector(pauseGame:) forControlEvents:UIControlEventTouchUpInside];
  [self.r4view addSubview:pauseButton];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)pauseGame:(id)sender
{
  [self.scene setPaused:!self.scene.isPaused];
  [sender setTitle:self.scene.isPaused ? @"Resume scene" : @"Pause scene" forState:UIControlStateNormal];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  return [super touchesMoved:touches withEvent:event];
//  bool success = NO;
//  return;
//  GLint viewport[4] = {};
//  glGetIntegerv(GL_VIEWPORT, viewport);
//  
//  for (int i = 0; i < 4; i++) {
//    viewport[i] /= [UIScreen mainScreen].scale;
//  }
//  
//  NSLog(@"%d, %d, %d, %d", viewport[0], viewport[1], viewport[2], viewport[3]);
//
//  CGPoint touchOrigin = [touches.anyObject locationInView:self.view];
//  NSLog(@"tap coordinates: %8.2f, %8.2f", touchOrigin.x, touchOrigin.y);
//  
//  GLKVector3 originInWindowNear = GLKVector3Make(touchOrigin.x, viewport[3] - touchOrigin.y, 0.0f);
//  GLKVector3 resultNear = GLKMathUnproject(originInWindowNear, self.scene.currentCamera.inversedTransform, self.scene.view.projectionMatrix, viewport, &success);
//  NSLog(@"NV: %@", NSStringFromGLKVector3(resultNear));
//  
//  GLKVector3 originInWindowFar = GLKVector3Make(touchOrigin.x, viewport[3] - touchOrigin.y, 1.0f);
//  GLKVector3 resultFar = GLKMathUnproject(originInWindowFar, self.scene.currentCamera.inversedTransform, self.scene.view.projectionMatrix, viewport, &success);
//  NSLog(@"NF: %@", NSStringFromGLKVector3(resultFar));
//  
//  GLKVector3 ray = GLKVector3Subtract(resultFar, resultNear);
//  NSLog(@"Ray: %@", NSStringFromGLKVector3(ray));
//  
//  GLfloat d = GLKVector3DotProduct(GLKVector3Negate(resultNear), GLKVector3Make(0, 1, 0)) / GLKVector3DotProduct(ray, GLKVector3Make(0, 1, 0));
//  GLKVector3 point = GLKVector3Add(resultNear, GLKVector3MultiplyScalar(ray, d));
//  NSLog(@"Point on xy: %@", NSStringFromGLKVector3(point));
//
//  [[self.scene childNodeWithName:@"sparks"] setPosition:point];

  //realY = ;
  
  // near
  
//  GLKVector3 originInWindowNear = GLKVector3Make(touchOrigin.x, realY, 0.0f);
//  
//  GLKVector3 result1 = GLKMathUnproject(originInWindowNear, modelView, projectionMatrix, viewport, &success);
//  NSAssert(success == YES, @"unproject failure");
//  
//  GLKMatrix4 matrix4_1 = GLKMatrix4Translate(GLKMatrix4Identity, result1.x, result1.y, 0.0f);
//  _squareUnprojectNear.modelMatrixUsage = GLKMatrix4Multiply(matrix4_1, _squareUnprojectNear.modelMatrixBase);
//  
//  GLKVector3 rayOrigin = GLKVector3Make(result1.x, result1.y, result1.z);
//  
//  // far
//  
//  GLKVector3 originInWindowFar = GLKVector3Make(touchOrigin.x, realY, 1.0f);
//  
//  GLKVector3 result2 = GLKMathUnproject(originInWindowFar, modelView, projectionMatrix, viewport, &success);
//  NSAssert(success == YES, @"unproject failure");
//  
//  GLKMatrix4 matrix4_2 = GLKMatrix4Translate(GLKMatrix4Identity, result2.x, result2.y, 0.0f);
//  
//  GLKVector3 rayDirection = GLKVector3Make(result2.x - rayOrigin.x, result2.y - rayOrigin.y, result2.z - rayOrigin.z);
}

@end
