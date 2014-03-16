//
//  R4Action.h
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

/*!
 @discussion Please refer to the SKAction class reference for more info.
 */

@interface R4Action : NSObject <NSCopying>

@property(nonatomic) NSTimeInterval duration;
@property(nonatomic) CGFloat speed;

+ (R4Action *)moveBy:(GLKVector3)offset duration:(NSTimeInterval)sec;
+ (R4Action *)moveTo:(GLKVector3)newPos duration:(NSTimeInterval)sec;

+ (R4Action *)scaleBy:(GLKVector3)scale duration:(NSTimeInterval)sec;
+ (R4Action *)scaleTo:(GLKVector3)scale duration:(NSTimeInterval)sec;

+ (R4Action *)rotateBy:(CGFloat)angle axis:(GLKVector3)axis duration:(NSTimeInterval)duration;

+ (R4Action *)repeatAction:(R4Action *)action count:(NSUInteger)count;
+ (R4Action *)repeatActionForever:(R4Action *)action;

+ (R4Action *)sequence:(NSArray *)actions;

- (R4Action *)reversedAction;

/* SpriteKit methods that are not implemented */
//@property(nonatomic) R4ActionTimingMode timingMode;

@end
