//
//  R4Node.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4View, R4Action, R4Scene, R4Texture, R4PhysicsBody;

@interface R4Node : UIResponder <NSCopying, NSCoding>

+ (instancetype)node;

@property (nonatomic, readonly) CGRect frame; // bounding box after projection
@property (nonatomic, readonly) R4Box boundingBox;

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKQuaternion orientation;
@property (nonatomic) GLKVector3 scale;

//@property (nonatomic) CGFloat zPosition;

@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat alpha;

@property (nonatomic, getter = isPaused) BOOL paused;
@property (nonatomic, getter = isHidden) BOOL hidden;
@property (getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@property (nonatomic, readonly) R4Node *parent;
@property (nonatomic, readonly) NSArray *children;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) R4Scene* scene;
//@property (nonatomic, strong) R4PhysicsBody *physicsBody;
@property (nonatomic, strong) NSMutableDictionary *userData;

- (CGRect)calculateAccumulatedFrame;

- (void)setUniformScale:(CGFloat)scale; // setScale

- (void)addChild:(R4Node *)node;
- (void)insertChild:(R4Node *)node atIndex:(NSInteger)index;

- (void)removeChildrenInArray:(NSArray *)nodes;
- (void)removeAllChildren;

- (void)removeFromParent;

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

- (BOOL)containsPoint:(CGPoint)p;
- (R4Node *)nodeAtPoint:(CGPoint)p;
- (NSArray *)nodesAtPoint:(CGPoint)p;

//- (GLKVector3)convertPoint:(GLKVector3)point fromNode:(R4Node *)node;
- (GLKVector3)convertPoint:(GLKVector3)point toNode:(R4Node *)node;

//- (BOOL)intersectsNode:(R4Node *)node;

@end


@interface UITouch (R4NodeTouches)
- (CGPoint)locationInNode:(R4Node *)node;
- (CGPoint)previousLocationInNode:(R4Node *)node;
@end
