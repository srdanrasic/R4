//
//  R4Action.m
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Action_.h"
#import "R4MoveAction.h"
#import "R4ScaleAction.h"
#import "R4RepeatAction.h"
#import "R4SequenceAction.h"

@implementation R4Action

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.finished = NO;
    self.speed = 1.0;
    vars = [self newActionPropertiesStruct];
  }
  return self;
}

- (void)dealloc
{
  free(vars);
}

- (R4ActionProperties *)newActionPropertiesStruct
{
  // TODO performance: Create pool of reusable R4ActionProperties
  return malloc(sizeof(R4ActionProperties));
}

+ (R4Action *)moveBy:(GLKVector3)offset duration:(NSTimeInterval)sec
{
  return [[R4MoveAction alloc] initMoveBy:offset duration:sec];
}

+ (R4Action *)moveTo:(GLKVector3)newPos duration:(NSTimeInterval)sec
{
  return [[R4MoveAction alloc] initMoveTo:newPos duration:sec];
}

+ (R4Action *)scaleBy:(GLKVector3)scale duration:(NSTimeInterval)sec
{
  return [[R4ScaleAction alloc] initScaleBy:scale duration:sec];
}

+ (R4Action *)scaleTo:(GLKVector3)scale duration:(NSTimeInterval)sec
{
  return [[R4ScaleAction alloc] initScaleTo:scale duration:sec];
}

+ (R4Action *)repeatAction:(R4Action *)action count:(NSUInteger)count
{
  return [[R4RepeatAction alloc] initWithAction:action count:count];
}

+ (R4Action *)repeatActionForever:(R4Action *)action
{
  return [[R4RepeatAction alloc] initForeverWithAction:action];
}

+ (R4Action *)sequence:(NSArray *)actions
{
  return [[R4SequenceAction alloc] initWithActions:actions];
}

- (R4Action *)reversedAction
{
  return nil;
}

- (void)updateWithTarget:(id)target forTime:(NSTimeInterval)time {}
- (void)willStartWithTarget:(id)target atTime:(NSTimeInterval)time {}
- (void)wasRemovedFromTarget:(id)target atTime:(NSTimeInterval)time {}
- (void)wasAddedToTarget:(id)target atTime:(NSTimeInterval)time {}
- (void)willResumeWithTarget:(id)target atTime:(NSTimeInterval)time {}
- (void)wasPausedWithTarget:(id)target atTime:(NSTimeInterval)time {}

@end
