//
//  R4PairKey.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4PairKey.h"

@implementation R4PairKey

+ (R4PairKey *)keyWithO1:(id)o1 o2:(id)o2
{
  R4PairKey *key = [[[self class] alloc] init];
  key->o1_ = o1;
  key->o2_ = o2;
  return key;
}

- (BOOL)isEqual:(id)object
{
  if (!self || !object) {
    return NO;
  } else if (self == object) {
    return YES;
  } else if ([object isKindOfClass:[self class]]) {
    R4PairKey *other = (R4PairKey *)object;
    return ((o1_ || o2_) && o1_ == other->o1_ && o2_ == other->o2_);
  } else {
    return NO;
  }
}

- (id)copyWithZone:(NSZone *)zone
{
  R4PairKey *key = [[[self class] alloc] init];
  key->o1_ = o1_;
  key->o2_ = o2_;
  return key;
}

@end
