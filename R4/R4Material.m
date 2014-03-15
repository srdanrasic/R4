//
//  R4Material.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Material.h"
#import "R4Technique.h"
#import "R4BasicPass.h"
#import "R4ADSPass.h"

@implementation R4Material

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.techniques = [NSMutableArray arrayWithObject:[[R4Technique alloc] init]];
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithTechniques:(NSArray *)techniques
{
  self = [super init];
  if (self) {
    for (id technique in techniques) {
      NSAssert([technique isKindOfClass:[R4Technique class]], @"Techniques array must contain only instances of class R4Technique or its descendants.");
    }
    self.techniques = [techniques mutableCopy];
    [self commonInit];
  }
  return self;
}

+ (R4Material *)materialWithTechnique:(R4Technique *)technique
{
  if (!technique) return nil;
  return [[[self class] alloc] initWithTechniques:@[technique]];
}

+ (R4Material *)basicMaterial
{
  return [[self class] materialWithTechnique:[R4Technique techniqueWithPass:[R4BasicPass pass]]];
}

+ (R4Material *)ADSMaterial
{
  return [[self class] materialWithTechnique:[R4Technique techniqueWithPass:[R4ADSPass pass]]];
}

- (void)commonInit
{
  self.ambientColor = GLKVector4Make(0.5, 0.5, 0.5, 0.5);
  self.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
  self.specularColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
  self.shininess = 0;
}

- (R4Technique *)optimalTechnique
{
  for (R4Technique *technique in self.techniques) {
    if ([technique isUsable]) {
      return technique;
    }
  }
  return nil;
}

- (R4Technique *)firstTechnique
{
  return [self.techniques firstObject];
}

- (R4Technique *)techniqueAtIndex:(NSUInteger)index
{
  return [self.techniques objectAtIndex:index];
}

@end
