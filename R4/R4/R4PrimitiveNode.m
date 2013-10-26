//
//  R4PrimitiveNode.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4PrimitiveNode.h"
#import "R4Node_.h"
#import "R4Renderer.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface R4PrimitiveNode () {
  GLuint _vertexBuffer;
}

@end

@implementation R4PrimitiveNode

GLfloat gCubeVertexData[216] =
{
  // Data layout for each line below is:
  // positionX, positionY, positionZ,     normalX, normalY, normalZ,
  0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  
  0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
  0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
  0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
  
  -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
  
  -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
  0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
  0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
  
  0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
  
  0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
  -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
  0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
  0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
  -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

+ (instancetype)box
{
  return [[[self class] alloc] initBox];
}

- (void)dealloc
{
  glDeleteBuffers(1, &_vertexBuffer);
}

- (instancetype)initBox
{
  self = [super init];
  if (self) {
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
  }
  return self;
}

- (void)draw
{
  glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
  glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
