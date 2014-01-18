//
//  R4Technique.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@interface R4Technique : NSObject

@property (nonatomic, assign) R4DeviceCPU minRequiredCPU;
@property (nonatomic, strong) NSMutableArray *passes;

- (instancetype)initWithPasses:(NSArray *)passes;
- (BOOL)isUsable;

@end
