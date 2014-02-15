//
//  R4RepeatAction.m
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4RepeatAction.h"

@implementation R4RepeatAction
{
  R4Action *_repeatedAction;
}

- (instancetype)initForeverWithAction:(R4Action *)action
{
  return [self initWithAction:action count:-1];
}

- (instancetype)initWithAction:(R4Action *)action count:(NSInteger)count
{
  self = [super init];
  if (self) {
    _repeatedAction = action;
    vars->count = count;
  }
  return self;
}

- (void)updateWithTarget:(id)target forTime:(NSTimeInterval)time
{
  [_repeatedAction updateWithTarget:target forTime:time];
  
  if (_repeatedAction.finished) {
    if (vars->count > 0) {
      vars->countLeft--;
    }
    
    if (vars->countLeft == 0) {
      self.finished = YES;
    } else {
      [_repeatedAction willStartWithTarget:target atTime:time];
    }
  }
}

- (void)willStartWithTarget:(id)target atTime:(NSTimeInterval)time
{
  vars->countLeft = vars->count;
  [_repeatedAction willStartWithTarget:target atTime:time];
}

- (void)wasRemovedFromTarget:(id)target atTime:(NSTimeInterval)time
{
  [_repeatedAction wasRemovedFromTarget:target atTime:time];
}

- (void)wasAddedToTarget:(id)target atTime:(NSTimeInterval)time
{
  self.finished = NO;
  [_repeatedAction wasAddedToTarget:target atTime:time];
}

- (void)willResumeWithTarget:(id)target atTime:(NSTimeInterval)time
{
  [_repeatedAction willResumeWithTarget:target atTime:time];
}

- (void)wasPausedWithTarget:(id)target atTime:(NSTimeInterval)time
{
  [_repeatedAction wasPausedWithTarget:target atTime:time];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4RepeatAction *repeatAction = [super copyWithZone:zone];
  repeatAction->_repeatedAction = [_repeatedAction copyWithZone:zone];
  return repeatAction;
}

@end
