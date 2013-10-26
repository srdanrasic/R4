//
//  R4MoveAction.m
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4MoveAction.h"
#import "R4Node_.h"

@implementation R4MoveAction

- (instancetype)initMoveBy:(GLKVector3)offset duration:(NSTimeInterval)duration
{
  self = [super init];
  if (self) {
    vars->param1 = offset;
    vars->duration = duration;
    vars->b1 = YES;
  }
  return self;
}

- (instancetype)initMoveTo:(GLKVector3)newPos duration:(NSTimeInterval)duration
{
  self = [super init];
  if (self) {
    vars->param1 = newPos;
    vars->duration = duration;
    vars->b1 = NO;
  }
  return self;
}

- (void)updateWithTarget:(id)target forTime:(NSTimeInterval)time
{
  CGFloat speed = self.speed * [target speed];
  
  NSTimeInterval dT = time - vars->previousTime;
  vars->elapsedTime += dT * speed;
  vars->previousTime = time;
  
  if (vars->elapsedTime > vars->duration) {
    dT = vars->elapsedTime - vars->duration;
    self.finished = YES;
  }
  
  GLKVector3 dPos = GLKVector3MultiplyScalar(vars->deltaV, dT * speed);
  GLKVector3 currentPos = [(R4Node *)target position];
  [(R4Node *)target setPosition:GLKVector3Add(currentPos, dPos)];
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
    vars->deltaV = GLKVector3MultiplyScalar(GLKVector3Subtract(vars->param1, node.position), 1.0 / vars->duration);
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
    return [[[self class] alloc] initMoveBy:GLKVector3Negate(vars->param1) duration:vars->duration];
  } else {
    return [[[self class] alloc] initMoveTo:vars->param1 duration:vars->duration];
  }
}

@end