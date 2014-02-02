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

/*!
 The Scene Manager object manages scene nodes for the Renderer. It provides mechanisms for ordering of the scene nodes, their culling and enumeration, all for the faster and optimised drawing. R4SceneManager protocol defines required interface for classes that implement such mechanisms.
 */
@protocol R4SceneManager <NSObject>
@required

- (instancetype)initWithScene:(R4Scene *)scene;

/*!
 Gets called by the scene whenever new node is added into the scene node tree.
 
 @param node Node that has been added.
 */
- (void)nodeAdded:(R4Node *)node;

/*!
 Gets called by the scene whenever new node is removed from the scene node tree.
 
 @param node Node that has been removed.
 */
- (void)nodeRemoved:(R4Node *)node;

/*!
 Provides means of enumeration of visible Drawable nodes (ones that conform to R4Drawable protocol) of the scene.
 
 @param block Block object that should get invoked with each Drawable Node.
 
 @discussion Preferably, nodes are enumerated in an order that makes rendering efficient, e.g. ordered by the Material, invisible Nodes or ones outside current camera's frustum skipped, etc.
 @discussion Nodes of type R4EmitterNode should usually be enumerated last.
 */
- (void)enumerateDrawableNodesWithBlock:(void (^)(R4Node<R4Drawable> *node))block;

/*!
 Provides means of enumeration of Light Nodes of the scene.
 
 @param node Node for which Lights are to be enumerated.
 @param block Block object that should get invoked with each Light Node.
 
 @discussion Preferably, nodes are enumerated by the distance from the Node.
 */
- (void)enumerateLightsFromNode:(R4Node *)node withBlock:(void (^)(R4LightNode *node))block;

@end
