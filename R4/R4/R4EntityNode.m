//
//  R4Entity.m
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4EntityNode.h"
#import "R4Mesh.h"

@implementation R4EntityNode

+ (R4EntityNode *)entityWithMesh:(R4Mesh *)mesh
{
  R4EntityNode *entity = [[R4EntityNode alloc] init];
  entity.mesh = mesh;
  return entity;
}

- (R4Material *)material
{
  if (_material == nil) {
    return self.mesh.material;
  } else {
    return _material;
  }
}

@end
