//
//  R4DrawableObject.h
//  R4
//
//  Created by Srđan Rašić on 15/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"


@interface R4DrawableObject : NSObject {
  @public
  GLuint vertexArray;
  GLuint vertexBuffer;
  GLuint indexBuffer;
  GLuint vertexCount;
  GLuint elementCount;
  GLuint stride;
  BOOL hasTextures;
  BOOL hasNormals;
}

@property (strong, nonatomic, readonly) GLKBaseEffect *effect;
@property (assign, nonatomic) R4Box geometryBoundingBox;

@end
