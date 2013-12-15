//
//  R4DrawableNode_private.h
//  R4
//
//  Created by Srđan Rašić on 15/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4DrawableNode.h"
#import "R4DrawableObject.h"

@interface R4DrawableNode ()

@property (strong, nonatomic) R4DrawableObject *drawableObject;

- (void)draw;

@end
