//
//  R4DefaultSceneManager.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4DefaultSceneManager.h"
#import "R4Node.h"
#import "R4EmitterNode.h"
#import "R4Drawable.h"
#import "R4LightNode.h"

#include <list>

typedef std::list<R4Node *> NodeList;

@interface R4DefaultSceneManager () {
  NodeList drawableList;
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
      drawableList.push_back(node);
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
    drawableList.remove(node);
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
}

- (void)enumerateLightsFromNode:(R4Node *)node withBlock:(void (^)(R4LightNode *))block
{
  for (R4LightNode *light in lightArray) {
    block(light);
  }
}

@end
