//
//  R4Scene.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@protocol R4SceneManager;
@class R4View, R4CameraNode, R4PhysicsWorld;

typedef NS_ENUM(NSInteger, R4SceneScaleMode) {
  R4SceneScaleModeFill,
  R4SceneScaleModeAspectFill,
  R4SceneScaleModeAspectFit,
  R4SceneScaleModeResizeFill
};

/*!
 An R4Scene object represents a scene of content. A scene is the root node in a tree of R4 nodes (R4Node). 
 These nodes provide content that the scene animates and renders for display. To display a scene, you present it from an R4View object.
 
 @discussion For more info and to learn more about non-documented items refer to the SKNode class reference.
 */
@interface R4Scene : R4Node

- (instancetype)initWithSize:(CGSize)size;
+ (instancetype)sceneWithSize:(CGSize)size;

@property (nonatomic) CGSize size;

/*!
 Defines how the scene is mapped to the view that presents it.
 
 @discussion It is possible for a scene’s size to differ from the size of the view it is presented in.
 The default value is R4SceneScaleModeResizeFill.
 */
@property (nonatomic) R4SceneScaleMode scaleMode;

@property (nonatomic, strong) R4Color *backgroundColor;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic, weak, readonly) R4View *view;

/*!
 The active camera the scene is looked from. Use this property to reposition the camera or change its properties.
 
 @discussion Changing this property will cause scene to be rendered from the view point of new camere in next frame.
 @discussion Default value is R4CameraNode object with position (0.0, 1.0, 2.0) and looking at scene origin (0.0, 0.0, 0.0).
 */
@property (nonatomic, strong) R4CameraNode *currentCamera;

/*!
 The active scene manager responsible for optimizing rendering process.
 
 @discussion Defaults to an instance of R4DefaultSceneManager class that perform basic sorting by material.
 */
@property (nonatomic, strong) id<R4SceneManager> sceneManager;

- (void)update:(NSTimeInterval)currentTime;
- (void)didEvaluateActions;
- (void)didSimulatePhysics;

- (void)didMoveToView:(R4View *)view;
- (void)willMoveFromView:(R4View *)view;
- (void)didChangeSize:(CGSize)oldSize;

/* SpriteKit methods that are not implemented */

//@property (nonatomic, readonly) R4PhysicsWorld *physicsWorld;
//- (GLKVector3)convertPointFromView:(CGPoint)point;
//- (CGPoint)convertPointToView:(GLKVector3)point;

@end
