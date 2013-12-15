//
//  R4DrawableNode.m
//  R4
//
//  Created by Srđan Rašić on 15/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4DrawableNode_private.h"

@implementation R4DrawableNode

- (void)draw
{
  @throw [NSException exceptionWithName:@"Error: - (void)draw; not implemented" reason:nil userInfo:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
  R4DrawableNode *drawableNode = [super copyWithZone:zone];
  drawableNode.drawableObject = self.drawableObject;
  return drawableNode;
}

@end
