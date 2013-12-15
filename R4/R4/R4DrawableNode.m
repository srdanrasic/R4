//
//  R4DrawableNode.m
//  R4
//
//  Created by Srđan Rašić on 15/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4DrawableNode_private.h"
#import "R4Node_private.h"

@implementation R4DrawableNode

- (R4Box)boundingBox
{
  return self.drawableObject.geometryBoundingBox;
}

- (void)prepareToDraw
{
}

- (id)copyWithZone:(NSZone *)zone
{
  R4DrawableNode *drawableNode = [super copyWithZone:zone];
  drawableNode.drawableObject = self.drawableObject;
  drawableNode.blendMode = self.blendMode;
  drawableNode.highlightColor = [self.highlightColor copyWithZone:zone];
  return drawableNode;
}

@end
