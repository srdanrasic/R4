//
//  R4MoveAction.h
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4ActionPrivate.h"

@interface R4RotateAction : R4Action

- (instancetype)initRotateBy:(CGFloat)angle axis:(GLKVector3)axis duration:(NSTimeInterval)duration;

@end
