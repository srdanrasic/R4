//
//  R4ModelNode__.h
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4ModelNode.h"

@interface R4ModelNode () {
  GLuint _vertexArray;
  GLuint _vertexBuffer;
  GLuint _indexBuffer;
  GLuint _vertexCount;
  GLuint _elementCount;
  GLuint _stride;
  GLKEffectPropertyMaterial *_material;
  GLKTextureInfo *_texture;
  BOOL _hasTextures;
  BOOL _hasNormals;
}

@end
