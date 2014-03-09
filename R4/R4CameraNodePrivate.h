//
//  R4Camera__.h
//  R4
//
//  Created by Srđan Rašić on 16/11/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4CameraNode.h"
#import "R4NodePrivate.h"

@interface R4CameraNode () {
  GLKVector3 _lookAt;
}

- (GLKMatrix4)inversedTransform;

@end
