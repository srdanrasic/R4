//
//  R4EmitterNode_Private.h
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4EmitterNode.h"

typedef struct {
  GLKMatrix4 MVM;
  GLKVector3 direction;
  GLKVector4 color;
  CGFloat colorBlendFactor;
  CGFloat alpha;
  CGFloat lifetime;
  CGFloat timeToLive;
} R4ParticleAttributes;

@interface R4EmitterNode ()

@property (nonatomic, assign) NSInteger particleCount;
@property (nonatomic, assign) R4ParticleAttributes *particleAttributes;

- (void)updateAtTime:(NSTimeInterval)time;

@end
