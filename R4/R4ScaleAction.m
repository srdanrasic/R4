//
//  R4ScaleAction.m
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4ScaleActionPrivate.h"
#import "R4NodePrivate.h"

@implementation R4ScaleAction

- (instancetype)initScaleBy:(GLKVector3)offset duration:(NSTimeInterval)duration
{
  self = [super init];
  if (self) {
    vars->param1 = offset;
    vars->duration = duration;
    vars->b1 = YES;
  }
  return self;
}

- (instancetype)initScaleTo:(GLKVector3)newScale duration:(NSTimeInterval)duration
{
  self = [super init];
  if (self) {
    vars->param1 = newScale;
    vars->duration = duration;
    vars->b1 = NO;
  }
  return self;
}

- (void)updateWithTarget:(id)target forTime:(NSTimeInterval)time
{
  CGFloat speed = self.speed * [(R4Node *)target speed];
  
  NSTimeInterval dT = time - vars->previousTime;
  vars->elapsedTime += dT * speed;
  vars->previousTime = time;
  
  if (vars->elapsedTime > vars->duration) {
    dT = vars->elapsedTime - vars->duration;
    self.finished = YES;
  }
  
  GLKVector3 dScale = GLKVector3MultiplyScalar(vars->deltaV, dT * speed);
  GLKVector3 currentScale = [(R4Node *)target scale];
  [(R4Node *)target setScale:GLKVector3Add(currentScale, dScale)];
}

- (void)willStartWithTarget:(id)target atTime:(NSTimeInterval)time
{
  self.finished = NO;
  
  vars->elapsedTime = 0;
  vars->previousTime = time;
  
  R4Node *node = target;
  
  if (vars->b1) {
    vars->deltaV = GLKVector3MultiplyScalar(vars->param1, 1.0 / vars->duration);
  } else {
    vars->deltaV = GLKVector3MultiplyScalar(GLKVector3Subtract(vars->param1, node.scale), 1.0 / vars->duration);
  }
}

- (void)wasAddedToTarget:(id)target atTime:(NSTimeInterval)time
{
  self.finished = NO;
}

- (void)willResumeWithTarget:(id)target atTime:(NSTimeInterval)time
{
  vars->previousTime = time;
}

- (R4Action *)reversedAction
{
  if (vars->b1) {
    return [[[self class] alloc] initScaleBy:GLKVector3Negate(vars->param1) duration:vars->duration];
  } else {
    return [[[self class] alloc] initScaleTo:vars->param1 duration:vars->duration];
  }
}

@end
