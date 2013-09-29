//
//  R4Scene.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Scene_Private.h"
#import "R4Node_Private.h"
#import "R4View_Private.h"

@implementation R4Scene

+ (instancetype)sceneWithSize:(CGSize)size
{
  return [[R4Scene alloc] initWithSize:size];
}

- (instancetype)initWithSize:(CGSize)size
{
  self = [super init];
  if (self) {
    self.size = size;
    self.anchorPoint = CGPointMake(0, 0);
    self.scaleMode = R4SceneScaleModeResizeFill;
    self.backgroundColor = [R4Color colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
  }
  return self;
}

- (R4Scene *)scene
{
  return self;
}

- (GLKVector3)position
{
  return GLKVector3Make(0, 0, 0);
}

- (GLKVector3)scale
{
  return GLKVector3Make(1, 1, 1);
}

- (GLKQuaternion)orientation
{
  return GLKQuaternionIdentity;
}

- (GLKMatrix4)modelViewMatrix
{
  return GLKMatrix4Identity;
}

- (CGRect)frame
{
  return CGRectMake(-self.size.width * self.anchorPoint.x, -self.size.height * self.anchorPoint.y,
                    self.size.width, self.size.height);
}

- (CGRect)calculateAccumulatedFrame
{
  return self.frame;
}


#pragma mark - Instance methods

- (void)didChangeSize:(CGSize)oldSize
{
}

@end
