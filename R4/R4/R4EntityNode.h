//
//  R4Entity.h
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@class R4Mesh, R4Material;

@interface R4EntityNode : R4Node

@property (nonatomic, strong) R4Mesh *mesh;
@property (nonatomic, strong) R4Material *material;

+ (R4EntityNode *)entityWithMesh:(R4Mesh *)mesh;

@end
