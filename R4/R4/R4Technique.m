//
//  R4Technique.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Technique.h"
#import "R4Pass.h"

@implementation R4Technique

- (instancetype)initWithPasses:(NSArray *)passes
{
  self = [super init];
  if (self) {
    for (id pass in passes) {
      NSAssert([pass isKindOfClass:[R4Pass class]], @"Passes array must contain only instances of class R4Pass or its descendants.");
    }
    self.passes = [passes mutableCopy];
  }
  return self;
}

- (BOOL)isUsable
{
  // TODO
  R4DeviceCPU cpu = R4DeviceCPUA4;
  return (self.minRequiredCPU >= cpu);
}

@end
