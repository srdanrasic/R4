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

@property (strong, nonatomic) R4Node *spaceship2;

@property (assign, nonatomic) NSTimeInterval timeOfLastUpdate;
@end

@implementation MyScene


- (void)didMoveToView:(R4View *)view
{
  R4Node *spaceship = [[R4ModelNode alloc] initWithModelNamed:@"stacy.obj"];
  spaceship.name = @"stacy";
  spaceship.position = GLKVector3Make(0, 0, 0);
  spaceship.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, -1);
  spaceship.scale = GLKVector3Make(2, 2, 2);
  spaceship.speed = 2;
  
  [self addChild:spaceship];
  
  self.spaceship2 = [R4PrimitiveNode box];
  self.spaceship2.name = @"spaceship";
  self.spaceship2.position = GLKVector3Make(1, 1.1, 0);
  self.spaceship2.scale = GLKVector3Make(0.1, 0.1, 3);
  ///spaceship2.orientation = GLKQuaternionMakeWithAngleAndAxis(0.6, 0, 1, -1);
  
  [spaceship addChild:self.spaceship2];
  
  [spaceship runAction:[R4Action repeatActionForever:[R4Action sequence:@[
                                                                          [R4Action scaleTo:GLKVector3Make(1, 1, 1) duration:1],
                                                                          [R4Action scaleTo:GLKVector3Make(1, 2, 1) duration:1]
                                                                          ]]]];
  [spaceship removeAllActions];
  
  self.currentCamera.position = GLKVector3Make(0, 2, 4);
  self.currentCamera.targetNode = self.spaceship2;
  
  self.timeOfLastUpdate = CACurrentMediaTime();
}

- (void)update:(NSTimeInterval)currentTime
{
  NSTimeInterval elapsedTime = currentTime - self.timeOfLastUpdate;
  //NSLog(@"FPS: %f", 1.0/elapsedTime);
  [self childNodeWithName:@"stacy"].orientation = GLKQuaternionMultiply([self childNodeWithName:@"stacy"].orientation,
                                                                            GLKQuaternionMakeWithAngleAndAxis(elapsedTime, 0, 1, 0));
  
  self.spaceship2.orientation = GLKQuaternionMultiply(self.spaceship2.orientation,
                                                     GLKQuaternionMakeWithAngleAndAxis(5*elapsedTime, 0, 1, 0));

  self.timeOfLastUpdate = currentTime;
  
  //NSLog(@"%@", NSStringFromGLKVector3([[self childNodeWithName:@"spaceship"] scale]));
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
  [self.view addSubview:self.r4view];
  
  self.scene = [MyScene sceneWithSize:CGSizeMake(320, 480)];
  self.scene.scaleMode = R4SceneScaleModeAspectFit;
  self.scene.anchorPoint = CGPointMake(0.0, 0.0);
  [self.r4view presentScene:self.scene];
  
  UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  pauseButton.frame = CGRectMake(10, 10, 200, 30);
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
