//
//  R4Action__.h
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Action.h"

typedef struct {
  union { GLKVector3 v1, param1, axis; };
  union { GLKVector3 v2, deltaV; };
  union { NSTimeInterval t1, duration; };
  union { NSTimeInterval t2, elapsedTime; };
  union { NSTimeInterval t3, previousTime; };
  union { CGFloat angle; };
  union { CGFloat deltaAngle; };
  BOOL b1;
  union { NSInteger i1, count, current; };
  union { NSInteger i2, countLeft; };
} R4ActionProperties;

@interface R4Action () {
  @protected
  R4ActionProperties *vars;
}

@property (nonatomic) BOOL finished;

- (void)updateWithTarget:(id)target forTime:(NSTimeInterval)time;
- (void)willStartWithTarget:(id)target atTime:(NSTimeInterval)time;
- (void)wasRemovedFromTarget:(id)target atTime:(NSTimeInterval)time;
- (void)wasAddedToTarget:(id)target atTime:(NSTimeInterval)time;
- (void)willResumeWithTarget:(id)target atTime:(NSTimeInterval)time;
- (void)wasPausedWithTarget:(id)target atTime:(NSTimeInterval)time;

@end


@interface R4ActionDescriptor : NSObject <NSCopying>

@property (nonatomic, strong) R4Action *action;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, copy) id block;

- (instancetype)initWithAction:(R4Action *)action key:(NSString *)key block:(id)block;

@end