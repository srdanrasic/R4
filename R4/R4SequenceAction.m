//
//  R4SequenceAction.m
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4SequenceAction.h"

@interface R4SequenceAction ()
@property (strong, nonatomic) NSArray *actions;
@end

@implementation R4SequenceAction

- (instancetype)initWithActions:(NSArray *)actions
{
  if (!actions || actions.count == 0) {
    return nil;
  }
  
  self = [super init];
  if (self) {
    self.actions = actions;
  }
  return self;
}

- (void)updateWithTarget:(id)target forTime:(NSTimeInterval)time
{
  NSInteger idx = vars->current;
  R4Action *currentAction = [self.actions objectAtIndex:idx];
  
  if ([currentAction finished]) {
    [currentAction wasRemovedFromTarget:target atTime:time];
    
    idx++;
    if (self.actions.count - 1 >= idx) {
      [[self.actions objectAtIndex:idx] wasAddedToTarget:target atTime:time];
      [[self.actions objectAtIndex:idx] willStartWithTarget:target atTime:time];
      vars->current = idx;
    } else {
      self.finished = YES;
    }
  } else {
    [currentAction updateWithTarget:target forTime:time];
  }
}

- (void)willStartWithTarget:(id)target atTime:(NSTimeInterval)time
{
  vars->current = 0;
  self.finished = NO;
  [[self.actions objectAtIndex:0] willStartWithTarget:target atTime:time];
}

- (void)wasRemovedFromTarget:(id)target atTime:(NSTimeInterval)time
{
  if (![[self.actions objectAtIndex:vars->current] finished]) {
    [[self.actions objectAtIndex:vars->current] wasRemovedFromTarget:target atTime:time];
  }
}

- (void)wasAddedToTarget:(id)target atTime:(NSTimeInterval)time
{
  self.finished = NO;
  vars->current = 0;
  [[self.actions objectAtIndex:0] wasAddedToTarget:target atTime:time];
}

- (void)willResumeWithTarget:(id)target atTime:(NSTimeInterval)time
{
  [[self.actions objectAtIndex:vars->current] willResumeWithTarget:target atTime:time];
}

- (void)wasPausedWithTarget:(id)target atTime:(NSTimeInterval)time
{
  [[self.actions objectAtIndex:vars->current] wasPausedWithTarget:target atTime:time];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4SequenceAction *sequenceAction = [super copyWithZone:zone];
  sequenceAction.actions = [[NSArray alloc] initWithArray:self.actions copyItems:YES];
  return sequenceAction;
}

@end
