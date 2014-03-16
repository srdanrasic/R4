//
//  R4Node.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4View, R4Action, R4Scene, R4Texture;

/*!
 The R4Node class is the fundamental building block of most scene content. All visual elements are drawn using predefined R4Node subclasses.
 
 @discussion For more info and to learn more about non-documented items refer to the SKNode class reference.
 */
@interface R4Node : UIResponder <NSCopying>

+ (instancetype)node;

/*!
 Bounding sphere of the node in world space.
 
 @discussion Unless overriden by subclass, this method returns R4Sphere with zero radius and center that equals to node position in world space.
 */
@property (nonatomic, readonly) R4Sphere boundingSphere;

/*!
 Bounding box of the node in world space.
 
 @discussion Unless overriden by subclass, this method returns R4OBB with zero half width, but with center and axes vectors calculated from node's model matrix.
 */
@property (nonatomic, readonly) R4OBB boundingBox;

/*!
 The position of the node in its parent's coordinate system.
 
 @discussion The default value is (0.0, 0.0, 0.0).
 */
@property (nonatomic) GLKVector3 position;

/*!
 The orientation of the node specified as a quaternion.
 
 @discussion The default value is GLKQuaternionIdentity. Use GLKQuaternionMake family of methods to create new orientation.
 */
@property (nonatomic) GLKQuaternion orientation;

/*!
 The orientation of the node specified as GLKVector3.
 
 @discussion The default value is (1.0, 1.0, 1.0), indicating no scaling is done in any direction.
 */
@property (nonatomic) GLKVector3 scale;

@property (nonatomic) CGFloat speed;

@property (nonatomic, getter = isPaused) BOOL paused;
@property (nonatomic, getter = isHidden) BOOL hidden;
@property (getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@property (nonatomic, readonly) R4Node *parent;
@property (nonatomic, readonly) NSArray *children;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) R4Scene* scene;
@property (nonatomic, strong) NSMutableDictionary *userData;

/*!
 Calculates a bounding sphere in world coordinate system that contains the content of the node and all of its descendants.
 
 @discussion The bounding sphere takes into the account the cumulative effect of the scale and orientation properties of each node in the subtree.
 */
- (R4Sphere)calculateAccumulatedBoundingSphere;

/*!
 Sets same scale value for all three directions.
 */
- (void)setUniformScale:(CGFloat)scale;

- (void)addChild:(R4Node *)node;
- (void)insertChild:(R4Node *)node atIndex:(NSInteger)index;

- (void)removeChildrenInArray:(NSArray *)nodes;
- (void)removeAllChildren;

- (void)removeFromParent;

/*!
 Searches for the first child node whose name equals given string.
 
 @param name Name searched for.
 @return Node whose name equals 'name' or 'nil' if not found.
 */
- (R4Node *)childNodeWithName:(NSString *)name;
- (void)enumerateChildNodesWithName:(NSString *)name usingBlock:(void (^)(R4Node *node, BOOL *stop))block;

- (BOOL)inParentHierarchy:(R4Node *)parent;

- (void)runAction:(R4Action *)action;
- (void)runAction:(R4Action *)action completion:(void (^)())block;
- (void)runAction:(R4Action *)action withKey:(NSString *)key;

- (BOOL)hasActions;
- (R4Action *)actionForKey:(NSString *)key;

- (void)removeActionForKey:(NSString *)key;
- (void)removeAllActions;

- (GLKVector3)convertPoint:(GLKVector3)point toNode:(R4Node *)node;
- (GLKVector3)convertPoint:(GLKVector3)point fromNode:(R4Node *)node;

- (BOOL)intersectsNode:(R4Node *)node;

/* SpriteKit methods that are not implemented */

//- (BOOL)containsPoint:(CGPoint)p;
//- (R4Node *)nodeAtPoint:(CGPoint)p;
//- (NSArray *)nodesAtPoint:(CGPoint)p;

//@property (nonatomic) CGFloat alpha;
//@property (nonatomic, readonly) CGRect frame;
//@property (nonatomic) CGFloat zPosition;
//@property (nonatomic, strong) R4PhysicsBody *physicsBody;

@end

@interface UITouch (R4NodeTouches)
- (GLKVector3)locationInNode:(R4Node *)node onPlane:(GLKVector3)planeNormal;
- (GLKVector3)previousLocationInNode:(R4Node *)node onPlane:(GLKVector3)planeNormal;
@end
