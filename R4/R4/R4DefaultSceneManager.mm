//
//  R4DefaultSceneManager.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4DefaultSceneManager.h"
#import "R4NodePrivate.h"
#import "R4EmitterNode.h"
#import "R4Drawable.h"
#import "R4LightNode.h"
#import "R4Scene.h"
#import "R4CameraNode.h"

#include <list>

typedef std::list<R4Node *> NodeList;

/* First emitters with additive blending.
 * Might also consider distance to camera in future.
 */
static bool compare_emitters(const R4EmitterNode *first, const R4EmitterNode *second)
{
  return [first particleBlendMode] != R4BlendModeAdd;
}

@interface R4DefaultSceneManager () {
  NodeList drawableList;
  NodeList emitterList;
  NSMutableArray *lightArray;
}

@end

@implementation R4DefaultSceneManager

- (instancetype)initWithScene:(R4Scene *)scene
{
  self = [super init];
  if (self) {
    lightArray = [NSMutableArray array];
  }
  return self;
}

- (void)nodeAdded:(R4Node *)node
{
  if ([node.class conformsToProtocol:@protocol(R4Drawable)]) {
    // TODO: Material sorting
    if ([node isKindOfClass:[R4EmitterNode class]]) {
      emitterList.push_back(node);
    } else {
      drawableList.push_front(node);
    }
  } else if ([node isKindOfClass:[R4LightNode class]]) {
    [lightArray addObject:node];
  }
}

- (void)nodeRemoved:(R4Node *)node
{
  if ([node.class conformsToProtocol:@protocol(R4Drawable)]) {
    if ([node isKindOfClass:[R4EmitterNode class]]) {
      emitterList.remove(node);
    } else {
      drawableList.remove(node);
    }
  } else if ([node isKindOfClass:[R4LightNode class]]) {
    [lightArray removeObject:node];
  }
}

- (void)enumerateDrawableNodesWithBlock:(void (^)(R4Node<R4Drawable> *))block
{
  for (NodeList::const_iterator iter = drawableList.begin(); iter != drawableList.end(); ++iter) {
    R4Node *node = *iter;
    // TODO: Basic frustum culling
    block((R4Node<R4Drawable> *)node);
  }
  
  emitterList.sort(compare_emitters);
  for (NodeList::const_iterator iter = emitterList.begin(); iter != emitterList.end(); ++iter) {
    R4Node *node = *iter;
    // TODO: Basic frustum culling
    block((R4Node<R4Drawable> *)node);
  }
}

- (void)enumerateLightsFromNode:(R4Node *)node withBlock:(void (^)(R4LightNode *))block
{
  for (R4LightNode *light in lightArray) {
    block(light);
  }
}

@end
