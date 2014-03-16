//
//  R4MoveAction.m
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4RotateActionPrivate.h"
#import "R4NodePrivate.h"

@implementation R4RotateAction

- (instancetype)initRotateBy:(CGFloat)angle axis:(GLKVector3)axis duration:(NSTimeInterval)duration
{
  self = [super init];
  if (self) {
    vars->angle = angle;
    vars->axis = axis;
    vars->duration = duration;
  }
  return self;
}

//- (instancetype)initMoveTo:(GLKVector3)newPos duration:(NSTimeInterval)duration
//{
//  self = [super init];
//  if (self) {
//    vars->param1 = newPos;
//    vars->duration = duration;
//    vars->b1 = NO;
//  }
//  return self;
//}

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
  
  GLKQuaternion dq = GLKQuaternionMakeWithAngleAndVector3Axis(vars->deltaAngle * dT, vars->axis);
  GLKQuaternion q = GLKQuaternionMultiply([(R4Node *)target orientation], dq);
  [(R4Node *)target setOrientation:q];
}

- (void)willStartWithTarget:(id)target atTime:(NSTimeInterval)time
{
  self.finished = NO;
  
  vars->elapsedTime = 0;
  vars->previousTime = time;
  
  //if (vars->b1) {
    vars->deltaAngle = vars->angle / vars->duration;
  //} else {
  //  vars->deltaV = GLKVector3MultiplyScalar(GLKVector3Subtract(vars->param1, node.position), 1.0 / vars->duration);
  //}
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
  //if (vars->b1) {
    return [[[self class] alloc] initRotateBy:-vars->angle axis:vars->axis duration:vars->duration];
  //} else {
  //  return [[[self class] alloc] initMoveTo:vars->param1 duration:vars->duration];
  //}
}

@end