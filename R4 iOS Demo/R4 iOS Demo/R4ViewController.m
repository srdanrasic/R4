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
#import <R4/R4PrimitiveNode.h>
#import <SpriteKit/SpriteKit.h>

@interface MyScene : R4Scene

@property (strong, nonatomic) R4Node *spaceship2;

@property (assign, nonatomic) NSTimeInterval timeOfLastUpdate;
@end

@implementation MyScene


- (void)didMoveToView:(R4View *)view
{
  R4Node *spaceship = [R4PrimitiveNode box];
  spaceship.name = @"spaceship";
  spaceship.position = GLKVector3Make(0, 0, -5);
  spaceship.orientation = GLKQuaternionMakeWithAngleAndAxis(0.6, 0, 1, -1);
  
  [self addChild:spaceship];
  
  self.spaceship2 = [R4PrimitiveNode box];
  self.spaceship2.name = @"spaceship";
  self.spaceship2.position = GLKVector3Make(0, 1, 0);
  self.spaceship2.scale = GLKVector3Make(0.1, 0.1, 3);
  ///spaceship2.orientation = GLKQuaternionMakeWithAngleAndAxis(0.6, 0, 1, -1);
  
  [spaceship addChild:self.spaceship2];
  
  self.timeOfLastUpdate = CACurrentMediaTime();
}

- (void)update:(NSTimeInterval)currentTime
{
  NSTimeInterval elapsedTime = currentTime - self.timeOfLastUpdate;
  NSLog(@"FPS: %f", 1.0/elapsedTime);
  [self childNodeWithName:@"spaceship"].orientation = GLKQuaternionMultiply([self childNodeWithName:@"spaceship"].orientation,
                                                                            GLKQuaternionMakeWithAngleAndAxis(1*elapsedTime, 0, 0, 1));
  self.spaceship2.orientation = GLKQuaternionMultiply(self.spaceship2.orientation,
                                                     GLKQuaternionMakeWithAngleAndAxis(5*elapsedTime, 0, 1, 0));

  self.timeOfLastUpdate = currentTime;
}

@end


@interface R4ViewController ()
@property (nonatomic, strong) R4View *r4view;
@property (nonatomic, strong) MyScene *scene;
@end

@implementation R4ViewController

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
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
