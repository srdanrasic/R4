//
//  R4Technique.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Pass;

/*!
 R4Technique describes how to render a R4Drawable. It does that by specifiying one or more passes that draw the object.
 
 @discussion Rendering is done by the R4Pass object. You can create more than one pass to achieve complex effects.
 
 @discussion There can be more techniques defined in one R4Material, but only the optimal one will be used for rendering. To determine which one is optimal for current device, class inspects technique's propertis that specify required device capabilities, like device or CPU model.
 */
@interface R4Technique : NSObject

@property (nonatomic, assign) R4DeviceCPU minRequiredCPU;
@property (nonatomic, strong) NSMutableArray *passes;

- (instancetype)init;
- (instancetype)initWithPasses:(NSArray *)passes;
+ (R4Technique *)techniqueWithPass:(R4Pass *)pass;

- (R4Pass *)firstPass;
- (R4Pass *)passAtIndex:(NSUInteger)index;
- (BOOL)isUsable;

@end
