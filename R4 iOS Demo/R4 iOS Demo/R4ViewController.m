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
#import <R4/R4PrimitiveNode.h>
#import <R4/R4ModelNode.h>
#import <R4/R4Camera.h>
#import <SpriteKit/SpriteKit.h>

@interface MyScene : R4Scene

@property (assign, nonatomic) NSTimeInterval timeOfLastUpdate;

@end

@implementation MyScene


- (void)didMoveToView:(R4View *)view
{
  R4DrawableNode *stacy = [[R4ModelNode alloc] initWithModelNamed:@"stacy.obj" normalize:YES center:NO];
  stacy.name = @"stacy";
  stacy.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, -1);
  stacy.scale = GLKVector3Make(1, 1, 1);
  stacy.speed = 1;
  stacy.blendMode = R4BlendModeAlpha;
  [self addChild:stacy];

  
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
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
  
  [stacy removeAllActions];
  stacy.highlightColor = [UIColor redColor];
  stacy.position = GLKVector3Make(0, 0, 3);

  R4DrawableNode *base = [R4PrimitiveNode box];
  base.name = @"base";
  base.position = GLKVector3Make(0, 0, 0);
  base.scale = GLKVector3Make(12, .01, 12);
  ///spaceship2.orientation = GLKQuaternionMakeWithAngleAndAxis(0.6, 0, 1, -1);
  base.highlightColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  [self addChild:base];

  self.currentCamera.position = GLKVector3Make(-4, 2, -1);
  self.currentCamera.targetNode = stacy;
  [stacy addChild:self.currentCamera];
  
  self.timeOfLastUpdate = CACurrentMediaTime();
}

- (void)update:(NSTimeInterval)currentTime
{
  NSTimeInterval elapsedTime = currentTime - self.timeOfLastUpdate;
  
  [self childNodeWithName:@"stacy"].orientation = GLKQuaternionMultiply([self childNodeWithName:@"stacy"].orientation, GLKQuaternionMakeWithAngleAndAxis(elapsedTime, 0, 1, 0));
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
  
  self.scene = [MyScene sceneWithSize:[UIScreen mainScreen].bounds.size];
  self.scene.scaleMode = R4SceneScaleModeResizeFill;
  [self.r4view presentScene:self.scene];
  
  UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  pauseButton.frame = CGRectMake(10, 10, 120, 30);
  [pauseButton setTitle:@"Pause scene" forState:UIControlStateNormal];
  [pauseButton addTarget:self action:@selector(pauseGame:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:pauseButton];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self.scene childNodeWithName:@"spaceship"].speed += 2;
}

@end
