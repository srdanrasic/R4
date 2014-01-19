//
//  R4Mesh.m
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Mesh.h"
#import "R4Material.h"
#import "R4Technique.h"
#import "R4Pass.h"
#import "R4Texture.h"
#import "R4TextureUnit.h"
#import "R4Shader.h"
#import "R4Shaders.h"

#include <fstream>
#include <vector>
#include <sstream>

static GLfloat gCubeVertexData[216] =
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

static GLfloat gPlainVertexData[48] =
{
  0.5f, 0.5f, 0.0f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0,
  -0.5f, 0.5f, 0.0f,         0.0f, 0.0f, 1.0f,   0.0f, 1.0,
  0.5f, -0.5f, 0.0f,         0.0f, 0.0f, 1.0f,   1.0f, 0.0,
  0.5f, -0.5f, 0.0f,         0.0f, 0.0f, 1.0f,   1.0f, 0.0,
  -0.5f, 0.5f, 0.0f,         0.0f, 0.0f, 1.0f,   0.0f, 1.0,
  -0.5f, -0.5f, 0.0f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0,
};

@implementation R4Mesh

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSDictionary *attribMap = @{@"in_position": @(R4VertexAttributePositionModelSpace),
                                @"in_texcoord": @(R4VertexAttributeTexCoord0)};
    
    R4Pass *pass = [[R4Pass alloc] init];
    pass.sceneBlend = R4BlendModeAlpha;
    pass.depthTest = pass.depthWrite = YES;
    pass.vertexShader = [[R4Shader alloc] initVertexShaderWithSourceString:vshPlainShaderSourceString attributeMapping:attribMap];
    pass.fragmentShader = [[R4Shader alloc] initFragmentShaderWithSourceString:fshPlainShaderSourceString attributeMapping:nil];
    [pass program];
    
    R4Technique *technique = [[R4Technique alloc] initWithPasses:@[pass]];
    
    self.material = [[R4Material alloc] initWithTechniques:@[technique]];
    vertexBuffer = GL_INVALID_VALUE;
    indexBuffer = GL_INVALID_VALUE;
  }
  return self;
}

+ (R4Mesh *)boxWithSize:(GLKVector3)size
{
  R4Mesh *mesh = [[R4Mesh alloc] init];
  mesh->elementCount = 36;
  
  glGenVertexArraysOES(1, &mesh->vertexArray);
  glBindVertexArrayOES(mesh->vertexArray);
  
  glGenBuffers(1, &mesh->vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, mesh->vertexBuffer);
  
  GLfloat vertexData[sizeof(gCubeVertexData)];
  for (int i = 0; i < sizeof(gCubeVertexData); i=i+6) {
    vertexData[i+0] = gCubeVertexData[i+0] * size.x;
    vertexData[i+1] = gCubeVertexData[i+1] * size.y;
    vertexData[i+2] = gCubeVertexData[i+2] * size.z;
    vertexData[i+3] = gCubeVertexData[i+3];
    vertexData[i+4] = gCubeVertexData[i+4];
    vertexData[i+5] = gCubeVertexData[i+5];
  }
  
  glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), vertexData, GL_STATIC_DRAW);
  
  glEnableVertexAttribArray(R4VertexAttributePositionModelSpace);
  glVertexAttribPointer(R4VertexAttributePositionModelSpace, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
  
  glEnableVertexAttribArray(R4VertexAttributeNormalModelSpace);
  glVertexAttribPointer(R4VertexAttributeNormalModelSpace, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
  
  glBindVertexArrayOES(0);
  
  mesh.geometryBoundingBox = R4BoxMake(GLKVector3Multiply(GLKVector3Make(-.5f, -.5f, -.5f), size), GLKVector3Multiply(GLKVector3Make(.5f, .5f, .5f), size));
  return mesh;
}

+ (R4Mesh *)plainWithSize:(CGSize)size
{
  R4Mesh *mesh = [[R4Mesh alloc] init];
  mesh->elementCount = 6;
  
  glGenVertexArraysOES(1, &mesh->vertexArray);
  glBindVertexArrayOES(mesh->vertexArray);
  
  glGenBuffers(1, &mesh->vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, mesh->vertexBuffer);
  
  GLfloat vertexData[sizeof(gPlainVertexData)];
  for (int i = 0; i < sizeof(gPlainVertexData); i=i+8) {
    vertexData[i+0] = gPlainVertexData[i+0] * size.width;
    vertexData[i+1] = gPlainVertexData[i+1];
    vertexData[i+2] = gPlainVertexData[i+2] * size.height;
    vertexData[i+3] = gPlainVertexData[i+3];
    vertexData[i+4] = gPlainVertexData[i+4];
    vertexData[i+5] = gPlainVertexData[i+5];
    vertexData[i+6] = gPlainVertexData[i+6];
    vertexData[i+7] = gPlainVertexData[i+7];
  }
  
  glBufferData(GL_ARRAY_BUFFER, sizeof(gPlainVertexData), vertexData, GL_STATIC_DRAW);
  
  glEnableVertexAttribArray(R4VertexAttributePositionModelSpace);
  glVertexAttribPointer(R4VertexAttributePositionModelSpace, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, BUFFER_OFFSET(0));
  
  glEnableVertexAttribArray(R4VertexAttributeNormalModelSpace);
  glVertexAttribPointer(R4VertexAttributeNormalModelSpace, 3, GL_FLOAT, GL_FALSE,  sizeof(GLfloat) * 8, BUFFER_OFFSET(12));
  
  glEnableVertexAttribArray(R4VertexAttributeTexCoord0);
  glVertexAttribPointer(R4VertexAttributeTexCoord0, 2, GL_FLOAT, GL_FALSE,  sizeof(GLfloat) * 8, BUFFER_OFFSET(24));
  
  //[mesh.material.firstTechnique.firstPass addTextureUnit:[R4TextureUnit textureUnitWithTexture:[R4Texture textureWithImageNamed:@"spark.png"]]];
  
  glBindVertexArrayOES(0);
  
  mesh.geometryBoundingBox = R4BoxMake(GLKVector3Make(-.5f, -.1f, -.5f), GLKVector3Make(.5f, .1f, .5f));
  return mesh;
}

+ (R4Mesh *)OBJMeshNamed:(NSString *)name normalize:(BOOL)normalize center:(BOOL)center
{
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *path = [resourcePath stringByAppendingPathComponent:name];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    return nil;
  }
  
  R4Mesh *mesh = [[R4Mesh alloc] init];
  
  std::ifstream obj_file([path cStringUsingEncoding:NSUTF8StringEncoding]);
  
  if (!obj_file.is_open()) {
    return NO;
  }
  
  struct FaceIndices {
    unsigned short position[3];
    unsigned short texcoord[3];
    unsigned short normal[3];
  };
  
  std::vector<GLKVector3> vertices;
  std::vector<GLKVector3> texcoords;
  std::vector<GLKVector3> normals;
  std::vector<FaceIndices> faces;
  
  float max_length = 0.0;
  
  GLKVector3 centerOffset = GLKVector3Make(0, 0, 0);
  GLKVector3 min = GLKVector3Make(9999, 9999, 9999);
  GLKVector3 max = GLKVector3Make(-9999, -9999, -9999);
  
  std::string material_filename;
  
  while (obj_file.good()) {
    char c;
    std::string line;
    std::getline(obj_file, line);
    std::stringstream ss(line);
    
    if (line[0] == 'v' && line[1] == ' ') {
      GLKVector3 p;
      ss >> c >> p.x >> p.y >> p.z;
      vertices.push_back(p);
      min = GLKVector3Minimum(min, p);
      max = GLKVector3Maximum(max, p);
      
      if (GLKVector3Length(p) > max_length)
        max_length = GLKVector3Length(p);
      
    } else if (line[0] == 'v' && line[1] == 't') {
      GLKVector3 p;
      ss >> c >> c >> p.x >> p.y;
      texcoords.push_back(p);
    } else if (line[0] == 'v' && line[1] == 'n') {
      GLKVector3 p;
      ss >> c >> c >> p.x >> p.y >> p.z;
      normals.push_back(p);
    } else if (line[0] == 'f' && line[1] == ' ') {
      FaceIndices fi;
      ss >> c;
      if (texcoords.size() > 0 && normals.size() > 0) {
        ss        >> fi.position[0] >> c >> fi.texcoord[0] >> c >> fi.normal[0]
        >> fi.position[1] >> c >> fi.texcoord[1] >> c >> fi.normal[1]
        >> fi.position[2] >> c >> fi.texcoord[2] >> c >> fi.normal[2];
      } else if (texcoords.size() == 0 && normals.size() > 0) {
        ss        >> fi.position[0] >> c >> c >> fi.normal[0]
        >> fi.position[1] >> c >> c >> fi.normal[1]
        >> fi.position[2] >> c >> c >> fi.normal[2];
      } else if (texcoords.size() == 0 && normals.size() == 0) {
        ss        >> fi.position[0] >> fi.position[1] >> fi.position[2];
      }
      
      faces.push_back(fi);
    } else if (line.compare(0, 6, std::string("mtllib")) == 0) {
      ss >> material_filename >> material_filename;
    }
  }
  
  if (normalize) {
    min = GLKVector3DivideScalar(min, max_length);
    max = GLKVector3DivideScalar(max, max_length);
  }
  
  centerOffset = GLKVector3Negate(GLKVector3Lerp(min, max, 0.5));
  
  if (center) {
    min = GLKVector3Add(min, centerOffset);
    max = GLKVector3Add(max, centerOffset);
  }
  
  mesh.geometryBoundingBox = R4BoxMake(min, max);
  
  mesh->hasTextures = texcoords.size() > 0;
  mesh->hasNormals = normals.size() > 0;
  
  mesh->vertexCount = (unsigned)vertices.size();
  mesh->elementCount = (unsigned)faces.size() * 3;
  mesh->stride = sizeof(GLKVector3);
  
  unsigned position_offset = 0;
  unsigned texcoord_offset = 0;
  unsigned normal_offset = 0;
  
  if (mesh->hasTextures) {
    mesh->stride += sizeof(GLKVector3);
    texcoord_offset = sizeof(GLKVector3);
  }
  
  if (mesh->hasNormals) {
    mesh->stride += sizeof(GLKVector3);
    normal_offset = texcoord_offset + sizeof(GLKVector3);
  }
  
  glGenVertexArraysOES(1, &mesh->vertexArray);
  glBindVertexArrayOES(mesh->vertexArray);
  
  glGenBuffers(2, &mesh->vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, mesh->vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, mesh->stride * mesh->vertexCount * sizeof(GLfloat), NULL, GL_STATIC_DRAW);
  unsigned char *vbo_array = (unsigned char *)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh->indexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh->elementCount * sizeof(unsigned short), NULL, GL_STATIC_DRAW);
  unsigned short *index_array = (unsigned short *)glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
  
  for (unsigned short i = 0; i < faces.size(); i++) {   // for all faces
    for (unsigned short j = 0; j < 3; j++) {  // for each vertex in face
      unsigned short index = i * 3 + j;
      index_array[index] = faces[i].position[j];  // copy index to array of indices
      
      GLKVector3 position = vertices[faces[i].position[j] - 1];
      
      if (normalize) {
        position = GLKVector3DivideScalar(position, max_length);
      }
      
      if (center) {
        position = GLKVector3Add(position, centerOffset);
      }
      
      ((GLKVector3 *)(vbo_array + index_array[index] * mesh->stride + position_offset))[0] = position;
      
      if (mesh->hasTextures)
        ((GLKVector3 *)(vbo_array + index_array[index] * mesh->stride + texcoord_offset))[0] = texcoords[faces[i].texcoord[j] - 1];
      
      if (mesh->hasNormals)
        ((GLKVector3 *)(vbo_array + index_array[index] * mesh->stride + normal_offset))[0] = normals[faces[i].normal[j] - 1];
    }
  }
  
  glUnmapBufferOES(GL_ARRAY_BUFFER);
  glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
  
  // Load material info
  if (material_filename.size() > 1) {
    NSString *directory = [path stringByDeletingLastPathComponent];
    NSString *materialPath = [directory stringByAppendingPathComponent:[NSString stringWithCString:material_filename.c_str() encoding:NSUTF8StringEncoding]];
    
    std::ifstream mat_file([materialPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    while (mat_file.good()) {
      char c;
      std::string line;
      std::getline(mat_file, line);
      std::stringstream ss(line);
      
      if (line[0] == 'K' && line[1] == 'a') {
        GLKVector4 color;
        ss >> c >> c >> color.r >> color.g >> color.b;
        mesh.material.ambientColor = color;
      } else if (line[0] == 'K' && line[1] == 'd') {
        GLKVector4 color;
        ss >> c >> c >> color.r >> color.g >> color.b;
        mesh.material.diffuseColor = color;
      } else if (line[0] == 'K' && line[1] == 's') {
        GLKVector4 color;
        ss >> c >> c >> color.r >> color.g >> color.b;
        mesh.material.specularColor = color;
      } else if (line[0] == 'N' && line[1] == 's') {
        float shininess;
        ss >> c >> c >> shininess;
        mesh.material.shininess = shininess;
      } else if (line.compare(0, 6, std::string("map_Kd")) == 0) {
        std::string texture_filename;
        ss >> texture_filename >> texture_filename;
        NSString *textureFilename = [NSString stringWithCString:texture_filename.c_str() encoding:NSUTF8StringEncoding];
        textureFilename = [[name stringByDeletingLastPathComponent] stringByAppendingPathComponent:textureFilename];
        [[[mesh.material techniqueAtIndex:0] passAtIndex:0] addTextureUnit:[R4TextureUnit textureUnitWithTexture:[R4Texture textureWithImageNamed:textureFilename]]];
      }
    }
  }
  
  glEnableVertexAttribArray(R4VertexAttributePositionModelSpace);
  glVertexAttribPointer(R4VertexAttributePositionModelSpace, 3, GL_FLOAT, GL_FALSE, mesh->stride, BUFFER_OFFSET(0));
  
  if (mesh->hasNormals) {
    glEnableVertexAttribArray(R4VertexAttributeNormalModelSpace);
    glVertexAttribPointer(R4VertexAttributeNormalModelSpace, 3, GL_FLOAT, GL_FALSE, mesh->stride, BUFFER_OFFSET(sizeof(GLKVector3)));
  }
  
  if (mesh->hasTextures) {
    glEnableVertexAttribArray(R4VertexAttributeTexCoord0);
    glVertexAttribPointer(R4VertexAttributeTexCoord0, 2, GL_FLOAT, GL_FALSE, mesh->stride, BUFFER_OFFSET(sizeof(GLKVector3)));
  }
  
  glBindVertexArrayOES(0);
  
  return mesh;
}

@end
