//
//  R4Base.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreGraphics/CGGeometry.h>

#define R4Color UIColor

typedef struct {
  GLKVector3 min;
  GLKVector3 max;
} R4Box;

static inline R4Box R4BoxMake(GLKVector3 min, GLKVector3 max)
{
  R4Box box = {min, max};
  return box;
}

static inline GLKVector3 R4BoxSize(R4Box box)
{
  return GLKVector3Subtract(box.max, box.min);
}

static inline NSString *NSStringFromR4Box(R4Box box)
{
  return [NSString stringWithFormat:@"{%@, %@}", NSStringFromGLKVector3(box.min), NSStringFromGLKVector3(box.max)];
}

static const R4Box R4BoxZero = {{0, 0, 0}, {0, 0, 0}};

