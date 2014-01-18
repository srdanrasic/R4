//
//  R4Material.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Technique;

@interface R4Material : NSObject

@property (nonatomic, strong) NSMutableArray *techniques;

- (instancetype)initWithTechniques:(NSArray *)techniques;
- (R4Technique *)optimalTechnique;

@end
