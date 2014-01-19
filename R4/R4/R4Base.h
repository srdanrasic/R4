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
#import <SpriteKit/SpriteKit.h>

#define R4Color UIColor

typedef NS_ENUM(NSInteger, R4DeviceCPU) {
  R4DeviceCPUA4,
  R4DeviceCPUA5,
  R4DeviceCPUA6
};

typedef NS_ENUM(NSInteger, R4BlendMode) {
  R4BlendModeAlpha        = 0,    // Blends the source and destination colors by multiplying the source alpha value.
  R4BlendModeAdd          = 1,    // Blends the source and destination colors by adding them up.
  R4BlendModeSubtract     = 2,    // Blends the source and destination colors by subtracting the source from the destination.
  R4BlendModeMultiply     = 3,    // Blends the source and destination colors by multiplying them.
  R4BlendModeMultiplyX2   = 4,    // Blends the source and destination colors by multiplying them and doubling the result.
  R4BlendModeScreen       = 5,    // FIXME: Description needed
  R4BlendModeReplace      = 6     // Replaces the destination with the source (ignores alpha).
};

typedef NS_ENUM(NSInteger, R4VertexAttribute) {
  R4VertexAttributePositionModelSpace,
  R4VertexAttributeNormalModelSpace,
  R4VertexAttributeTexCoord0,
  R4VertexAttributeTexCoord1,
  R4VertexAttributeColor,
  R4VertexAttributeColorBlendFactor,
  R4VertexAttributeMVM,
  R4VertexAttributeCount
};



typedef struct {
  GLKVector3 startPoint;
  GLKVector3 direction;
} R4Ray;

typedef union {
  struct { GLKVector3 min; GLKVector3 max; };
  GLKVector3 bounds[2];
} R4Box;

static inline R4Ray R4RayMake(GLKVector3 startPoint, GLKVector3 direction)
{
  R4Ray ray = {startPoint, GLKVector3Normalize(direction)};
  return ray;
}

static inline NSString *NSStringFromR4Ray(R4Ray ray)
{
  return [NSString stringWithFormat:@"{%@, %@}", NSStringFromGLKVector3(ray.startPoint), NSStringFromGLKVector3(ray.direction)];
}


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

static const R4Box R4BoxZero = { .min = {0, 0, 0}, .max = {0, 0, 0}};

static inline CGFloat randCGFloat(CGFloat min, CGFloat max)
{
  return (min + (arc4random() % 1000) / 1000.0 * (max - min));
}

static inline GLKVector3 randGLKVector3(CGFloat min, CGFloat max)
{
  return GLKVector3Make(randCGFloat(min, max), randCGFloat(min, max), randCGFloat(min, max));
}

static inline GLKVector4 randGLKVector4(CGFloat min, CGFloat max)
{
  return GLKVector4Make(randCGFloat(min, max), randCGFloat(min, max), randCGFloat(min, max), randCGFloat(min, max));
}

