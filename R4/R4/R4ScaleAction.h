//
//  R4ScaleAction.h
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4ActionPrivate.h"

@interface R4ScaleAction : R4Action

- (instancetype)initScaleBy:(GLKVector3)offset duration:(NSTimeInterval)duration;
- (instancetype)initScaleTo:(GLKVector3)newScale duration:(NSTimeInterval)duration;

@end
