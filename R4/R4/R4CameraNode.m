//
//  R4Camera.m
//  R4
//
//  Created by Srđan Rašić on 16/11/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4CameraNodePrivate.h"

@implementation R4CameraNode

+ (instancetype)cameraAtPosition:(GLKVector3)position lookingAt:(GLKVector3)lookingAt
{
  return [[[self class] alloc] initWithPosition:position lookAt:lookingAt];
}

- (instancetype)initWithPosition:(GLKVector3)position lookAt:(GLKVector3)lookAt
{
  self = [super init];
  if (self) {
    self.position = position;
    _lookAt = lookAt;
    _upVector = GLKVector3Make(0, 1, 0);
  }
  return self;
}

- (GLKMatrix4)inversedTransform
{
  // TODO Cache
  
  GLKVector3 eye = self.positionWorldSpace;
  GLKVector3 up = _upVector;
  GLKVector3 center;
  
  if (self.targetNode) {
    center = self.targetNode.positionWorldSpace;
  } else {
    center = _lookAt;
  }
  
  GLKMatrix4 transform = GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
  
  return transform;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
  [super setUserInteractionEnabled:NO];
}

@end
