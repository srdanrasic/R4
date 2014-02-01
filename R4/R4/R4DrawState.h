//
//  R4DrawState.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@interface R4DrawState : NSObject {
@public
  GLKMatrix4 modelMatrix;
  GLKMatrix4 viewMatrix;
  GLKMatrix4 projectionMatrix;
  GLKMatrix4 viewProjectionMatrix;
  GLKMatrix4 modelViewMatrix;
  GLKMatrix4 modelViewProjectionMatrix;
  
  GLint program;
  GLint textures[R4_MAX_TEXTURE_UNITS];     // texture[gl texture unit idx] = gl texture name
  
  R4BlendMode blendMode;
}

@end