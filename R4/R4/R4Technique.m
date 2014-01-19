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

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.passes = [NSMutableArray arrayWithObject:[[R4Pass alloc] init]];
  }
  return self;
}

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

- (R4Pass *)firstPass
{
  return [self.passes firstObject];
}

- (R4Pass *)passAtIndex:(NSUInteger)index
{
  return [self.passes objectAtIndex:index];
}

- (BOOL)isUsable
{
  // TODO
  R4DeviceCPU cpu = R4DeviceCPUA4;
  return (self.minRequiredCPU >= cpu);
}

@end
