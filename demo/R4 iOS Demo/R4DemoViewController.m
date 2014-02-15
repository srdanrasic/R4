//
//  R4ViewController.m
//  R4 iOS Demo
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4DemoViewController.h"
#import "R4DemoScene.h"

@interface R4DemoViewController ()

@property (nonatomic, strong) R4View *r4view;
@property (nonatomic, strong) R4DemoScene *scene;

@end


@implementation R4DemoViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.r4view = [[R4View alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.r4view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.r4view.showFPS = YES;
  [self.view addSubview:self.r4view];
  
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width * scale, [UIScreen mainScreen].bounds.size.height * scale);
  self.scene = [R4DemoScene sceneWithSize:size];
  self.scene.scaleMode = R4SceneScaleModeResizeFill;
  [self.r4view presentScene:self.scene];
  
  UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  pauseButton.frame = CGRectMake(10, 10, 120, 30);
  [pauseButton setTitle:@"Pause scene" forState:UIControlStateNormal];
  [pauseButton addTarget:self action:@selector(pauseGame:) forControlEvents:UIControlEventTouchUpInside];
  [self.r4view addSubview:pauseButton];
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)pauseGame:(id)sender
{
  [self.scene setPaused:!self.scene.isPaused];
  [sender setTitle:self.scene.isPaused ? @"Resume scene" : @"Pause scene" forState:UIControlStateNormal];
}

@end
