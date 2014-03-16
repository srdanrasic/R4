//
//  R4Entity.h
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"
#import "R4Drawable.h"

@class R4Mesh, R4Material;

/*!
 Entity node represents a drawable Mesh - an objects that encapsulates some drawable geometry.
 */
@interface R4EntityNode : R4Node <R4Drawable>

@property (nonatomic, strong) R4Mesh *mesh;
@property (nonatomic, strong) R4Material *material;
@property (nonatomic, assign) BOOL showBoundingVolume;

+ (R4EntityNode *)entityWithMesh:(R4Mesh *)mesh;

@end
