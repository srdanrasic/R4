//
//  R4MoveAction.h
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Action_.h"

@interface R4MoveAction : R4Action

- (instancetype)initMoveBy:(GLKVector3)offset duration:(NSTimeInterval)duration;
- (instancetype)initMoveTo:(GLKVector3)newPos duration:(NSTimeInterval)duration;

@end
