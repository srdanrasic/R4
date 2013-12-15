//
//  R4Action.m
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Action_private.h"
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

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4Action *action = [[[self class] allocWithZone:zone] init];
  action.duration = self.duration;
  action.speed = self.speed;
  action.finished = self.finished;
  memcpy(action->vars, vars, sizeof(R4ActionProperties));
  return action;
}

@end


@implementation R4ActionDescriptor

- (instancetype)initWithAction:(R4Action *)action key:(NSString *)key block:(id)block
{
  self = [super init];
  if (self) {
    self.action = action;
    self.key = key;
    self.block = block;
  }
  return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4ActionDescriptor *descriptor = [[[self class] allocWithZone:zone] init];
  descriptor.action = [self.action copyWithZone:zone];
  descriptor.key = [self.key copyWithZone:zone];
  descriptor.block = [self.block copyWithZone:zone];
  descriptor.started = self.started;
  return descriptor;
}

@end
