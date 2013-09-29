//
//  R4Transition.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class CIFilter;

typedef NS_ENUM(NSInteger, R4TransitionDirection) {
  R4TransitionDirectionUp,
  R4TransitionDirectionDown,
  R4TransitionDirectionRight,
  R4TransitionDirectionLeft
};


@interface R4Transition : NSObject

+ (R4Transition *)crossFadeWithDuration:(NSTimeInterval)sec;

+ (R4Transition *)fadeWithDuration:(NSTimeInterval)sec;

+ (R4Transition *)fadeWithColor:(R4Color *)color duration:(NSTimeInterval)sec;

+ (R4Transition *)flipHorizontalWithDuration:(NSTimeInterval)sec;
+ (R4Transition *)flipVerticalWithDuration:(NSTimeInterval)sec;

+ (R4Transition *)revealWithDirection:(R4TransitionDirection)direction duration:(NSTimeInterval)sec;
+ (R4Transition *)moveInWithDirection:(R4TransitionDirection)direction duration:(NSTimeInterval)sec;
+ (R4Transition *)pushWithDirection:(R4TransitionDirection)direction duration:(NSTimeInterval)sec;

+ (R4Transition *)doorsOpenHorizontalWithDuration:(NSTimeInterval)sec;
+ (R4Transition *)doorsOpenVerticalWithDuration:(NSTimeInterval)sec;
+ (R4Transition *)doorsCloseHorizontalWithDuration:(NSTimeInterval)sec;
+ (R4Transition *)doorsCloseVerticalWithDuration:(NSTimeInterval)sec;

+ (R4Transition *)doorwayWithDuration:(NSTimeInterval)sec;

+ (R4Transition *)transitionWithCIFilter:(CIFilter*)filter duration:(NSTimeInterval)sec;

@property (nonatomic) BOOL pausesIncomingScene;
@property (nonatomic) BOOL pausesOutgoingScene;

@end
