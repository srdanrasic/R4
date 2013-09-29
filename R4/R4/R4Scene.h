//
//  R4Scene.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@class R4View, R4PhysicsWorld;

typedef NS_ENUM(NSInteger, R4SceneScaleMode) {
  R4SceneScaleModeFill,
  R4SceneScaleModeAspectFill,
  R4SceneScaleModeAspectFit,
  R4SceneScaleModeResizeFill
};


@interface R4Scene : R4Node

- (instancetype)initWithSize:(CGSize)size;
+ (instancetype)sceneWithSize:(CGSize)size;

@property (nonatomic) CGSize size;
@property (nonatomic) R4SceneScaleMode scaleMode;
@property (nonatomic, strong) R4Color *backgroundColor;
@property (nonatomic) CGPoint anchorPoint;
//@property (nonatomic, readonly) R4PhysicsWorld *physicsWorld;
@property (nonatomic, weak, readonly) R4View *view;

- (GLKVector3)convertPointFromView:(CGPoint)point;
- (CGPoint)convertPointToView:(GLKVector3)point;

- (void)update:(NSTimeInterval)currentTime;
- (void)didEvaluateActions;
- (void)didSimulatePhysics;

- (void)didMoveToView:(R4View *)view;
- (void)willMoveFromView:(R4View *)view;
- (void)didChangeSize:(CGSize)oldSize;

@end
