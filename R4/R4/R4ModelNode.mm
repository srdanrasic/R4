//
//  R4ModelNode.m
//  R4
//
//  Created by Srđan Rašić on 26/10/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4ModelNode_.h"
#include <fstream>
#include <vector>
#include <sstream>

@implementation R4ModelNode

- (instancetype)initWithModelNamed:(NSString *)name
{
  self = [super init];
  if (self) {
    BOOL loaded = NO;
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [resourcePath stringByAppendingPathComponent:name];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
      return nil;
    }
    
    if ([path hasSuffix:@".obj"]) {
      loaded = [self loadObjFile:path];
    } // TODO add other formats
    
    if (!loaded) {
      return nil;
    }
  }
  return self;
}

- (BOOL)loadObjFile:(NSString *)path
{
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
  
  _hasTextures = texcoords.size() > 0;
  _hasNormals = normals.size() > 0;
  
  _vertexCount = (unsigned)vertices.size();
  _elementCount = (unsigned)faces.size() * 3;
  _stride = sizeof(GLKVector3);
  
  unsigned position_offset = 0;
  unsigned texcoord_offset = 0;
  unsigned normal_offset = 0;
  
  if (_hasTextures) {
    _stride += sizeof(GLKVector3);
    texcoord_offset = sizeof(GLKVector3);
  }
  
  if (_hasNormals) {
    _stride += sizeof(GLKVector3);
    normal_offset = texcoord_offset + sizeof(GLKVector3);
  }
  
  //shared_ptr<VertexData> indices(new BufferedVertexData(element_count * sizeof(unsigned), 0, GL_STATIC_DRAW, GL_ELEMENT_ARRAY_BUFFER, NULL));
  //shared_ptr<VertexData> vbo(new BufferedVertexData(stride * vertex_count, stride, GL_STATIC_DRAW, GL_ARRAY_BUFFER, NULL));
  
  glGenVertexArraysOES(1, &_vertexArray);
  glBindVertexArrayOES(_vertexArray);
  
  glGenBuffers(2, &_vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, _stride * _vertexCount * sizeof(GLfloat), NULL, GL_STATIC_DRAW);
  unsigned char *vbo_array = (unsigned char *)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, _elementCount * sizeof(unsigned short), NULL, GL_STATIC_DRAW);
  unsigned short *index_array = (unsigned short *)glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);

  
  for (unsigned short i = 0; i < faces.size(); i++) {   // for all faces
    for (unsigned short j = 0; j < 3; j++) {  // for each vertex in face
      unsigned short index = i * 3 + j;
      index_array[index] = faces[i].position[j];  // copy index to array of indices
      
      ((GLKVector3 *)(vbo_array + index_array[index] * _stride + position_offset))[0] = GLKVector3DivideScalar(vertices[faces[i].position[j] - 1],max_length);
      
      if (_hasTextures)
        ((GLKVector3 *)(vbo_array + index_array[index] * _stride + texcoord_offset))[0] = texcoords[faces[i].texcoord[j] - 1];
      
      if (_hasNormals)
        ((GLKVector3 *)(vbo_array + index_array[index] * _stride + normal_offset))[0] = normals[faces[i].normal[j] - 1];
    }
  }
  
  glUnmapBufferOES(GL_ARRAY_BUFFER);
  glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
  

  // Load material info
  if (material_filename.size() > 1) {
    NSString *directory = [path stringByDeletingLastPathComponent];
    NSString *materialPath = [directory stringByAppendingPathComponent:[NSString stringWithCString:material_filename.c_str() encoding:NSUTF8StringEncoding]];
    
    std::ifstream mat_file([materialPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (mat_file.good()) {
      _material = [[GLKEffectPropertyMaterial alloc] init];
    }
    
    while (mat_file.good()) {
      char c;
      std::string line;
      std::getline(mat_file, line);
      std::stringstream ss(line);
      
      if (line[0] == 'K' && line[1] == 'a') {
        GLKVector4 color;
        ss >> c >> c >> color.r >> color.g >> color.b;
        _material.ambientColor = color;
      } else if (line[0] == 'K' && line[1] == 'd') {
        GLKVector4 color;
        ss >> c >> c >> color.r >> color.g >> color.b;
         _material.diffuseColor = color;
      } else if (line[0] == 'K' && line[1] == 's') {
        GLKVector4 color;
        ss >> c >> c >> color.r >> color.g >> color.b;
        _material.specularColor = color;
      } else if (line[0] == 'N' && line[1] == 's') {
        float shininess;
        ss >> c >> c >> shininess;
        _material.shininess = shininess;
      } else if (line.compare(0, 6, std::string("map_Kd")) == 0) {
        std::string texture_filename;
        ss >> texture_filename >> texture_filename;
        NSString *texturePath = [directory stringByAppendingPathComponent:[NSString stringWithCString:texture_filename.c_str() encoding:NSUTF8StringEncoding]];
        
        NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft:[NSNumber numberWithBool:YES]};
        _texture = [GLKTextureLoader textureWithContentsOfFile:texturePath options:options error:nil];
      }
    }
  }
  
  
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, _stride, BUFFER_OFFSET(0));
  
  if (_hasNormals) {
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, _stride, BUFFER_OFFSET(sizeof(GLKVector3)));
  }
  
  if (_hasTextures) {
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, _stride, BUFFER_OFFSET(sizeof(GLKVector3)));
  }

  glBindVertexArrayOES(0);
  
  return YES;
}

- (void)prepareEffect:(GLKBaseEffect *)effect
{
  effect.material.ambientColor = _material.ambientColor;
  effect.material.diffuseColor = _material.diffuseColor;
  effect.material.specularColor = _material.specularColor;
  effect.material.shininess = _material.shininess;
  
  if (_texture) {
    effect.texture2d0.name = _texture.name;
    effect.texture2d0.enabled = GL_TRUE;
  } else {
    effect.texture2d0.enabled = GL_FALSE;
  }
}

- (void)draw
{
  glDisable(GL_CULL_FACE);
  glBindVertexArrayOES(_vertexArray);
  glDrawElements(GL_TRIANGLES, _elementCount, GL_UNSIGNED_SHORT, BUFFER_OFFSET(0));
}

@end