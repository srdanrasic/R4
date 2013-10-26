//
//  R4RepeatAction.h
//  R4
//
//  Created by Srđan Rašić on 10/5/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Action_.h"

@interface R4RepeatAction : R4Action

- (instancetype)initForeverWithAction:(R4Action *)action;
- (instancetype)initWithAction:(R4Action *)action count:(NSInteger)count;

@end
