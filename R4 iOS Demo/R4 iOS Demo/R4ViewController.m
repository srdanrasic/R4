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
#import <SpriteKit/SpriteKit.h>

@interface R4ViewController ()
@property (nonatomic, strong) R4View *r4view;
@property (nonatomic, strong) R4Scene *scene;
@property (nonatomic, strong) UIView *rect;
@end

@implementation R4ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	self.r4view = [[R4View alloc] initWithFrame:self.view.bounds];
  self.r4view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:self.r4view];
  
  self.scene = [R4Scene sceneWithSize:CGSizeMake(320, 320)];
  self.scene.anchorPoint = CGPointMake(0.5, 0.5);
  
  R4Node *spaceship = [R4Node node];
  spaceship.name = @"spaceship";
  spaceship.position = GLKVector3Make(0, 0, -1);
  
  [self.scene addChild:spaceship];
  [self.r4view presentScene:self.scene];
  
  self.rect = [[UIView alloc] init];
  self.rect.backgroundColor = [UIColor redColor];
  [self.r4view addSubview:self.rect];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  self.rect.frame = [self calcRect];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
}

- (CGRect)calcRect
{
  CGRect frame = [self.scene childNodeWithName:@"spaceship"].calculateAccumulatedFrame;
  frame.origin = [self.r4view convertPoint:frame.origin fromScene:self.scene];
  frame.origin = CGPointMake(frame.origin.x, frame.origin.y - frame.size.height);
  return frame;
}
@end
