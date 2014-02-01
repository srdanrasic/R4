//
//  R4SceneManager.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@protocol R4Drawable;
@class R4Scene, R4Node, R4LightNode;

@protocol R4SceneManager <NSObject>
@required

- (instancetype)initWithScene:(R4Scene *)scene;

- (void)nodeAdded:(R4Node *)node;
- (void)nodeRemoved:(R4Node *)node;

- (void)enumerateDrawableNodesWithBlock:(void (^)(R4Node<R4Drawable> *node))block;
- (void)enumerateLightsFromNode:(R4Node *)node withBlock:(void (^)(R4LightNode *node))block;


@end
