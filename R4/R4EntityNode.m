//
//  R4Entity.m
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4EntityNode.h"
#import "R4Mesh.h"

@implementation R4EntityNode

+ (R4EntityNode *)entityWithMesh:(R4Mesh *)mesh
{
  R4EntityNode *entity = [[[self class] alloc] init];
  entity.mesh = mesh;
  return entity;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4EntityNode *node = [super copyWithZone:zone];
  node.mesh = self.mesh;
  node.material = self.material;
  node.showBoundingVolume = self.showBoundingVolume;
  return node;
}

- (R4Sphere)boundingSphere
{
  R4Sphere s = [super boundingSphere];
  s.center = GLKVector3Add(s.center, _mesh.geometryBoundingSphere.center);
  s.radius = _mesh.geometryBoundingSphere.radius;
  return s;
}

- (R4OBB)boundingBox
{
  R4OBB obb = [super boundingBox];
  obb.c = GLKVector3Add(obb.c, _mesh.geometryBoundingBox.center);
  obb.e = _mesh.geometryBoundingBox.halfWidth;
  return obb;
}

- (R4Material *)material
{
  if (_material == nil) {
    return _mesh.material;
  } else {
    return _material;
  }
}

- (void)prepareToDraw
{
  glBindVertexArrayOES(_mesh->vertexArray);
}

- (void)draw
{
  if ((_mesh->indexBuffer != GL_INVALID_VALUE)) {
    glDrawElements(_mesh->drawPrimitive, _mesh->elementCount, GL_UNSIGNED_SHORT, BUFFER_OFFSET(0));
  } else {
    glDrawArrays(_mesh->drawPrimitive, 0, _mesh->elementCount);
  }
}

@end
