//
//  R4Camera__.h
//  R4
//
//  Created by Srđan Rašić on 16/11/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Camera.h"
#import "R4Node_.h"

@interface R4Camera () {
  GLKVector3 _lookAt;
  GLKVector3 _upVector;
}

- (GLKMatrix4)inversedTransform;

@end
