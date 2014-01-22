//
//  R4EmitterNode_Private.h
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4EmitterNode.h"

@class R4Mesh, R4Material;

typedef struct {
  GLKMatrix4 MVM;
  GLKVector4 color;
  GLKVector3 direction;
  CGFloat colorBlendFactor;
  
  CGFloat lifetime;
  CGFloat timeToLive;
  GLKVector3 initialPosition;
  GLKVector4 initialColor;
  CGFloat initialScale;
  CGFloat initialColorBlendFactor;
  CGFloat speed;
} R4ParticleAttributes;

@interface R4EmitterNode () {
  @public
  GLuint particleAttributesVertexBuffer;
  GLuint particleAttributesVertexArray;
  NSInteger maxParticeCount;
}

@property (nonatomic, assign) NSInteger particleCount;
@property (nonatomic, assign) R4ParticleAttributes *particleAttributes;
@property (nonatomic, strong) R4Mesh *particleMesh;
@property (nonatomic, strong) R4Material *material;

- (void)updateAtTime:(NSTimeInterval)time;

@end
