//
//  R4PrimitiveNode.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@interface R4PrimitiveNode : R4Node

+ (instancetype)planeWithSize:(CGSize)size;
+ (instancetype)boxWithSize:(GLKVector3)size;
+ (instancetype)spereWithRadius:(CGFloat)radius;

@end
