//
//  R4View.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Scene, R4Node, R4Transition, R4Texture;

/*!
 An R4View object is a view that displays 3D scene content. This content is provided by an R4Scene object.
 
 @discussion You present a scene by calling the view’s presentScene: method. When a scene is presented by the view,
 it alternates between running its simulation (which animates the content) and rendering the content for display.
 You can pause the scene by setting the view’s paused property to YES.
 
 @discussion For the non-documented items refer to the SKView class reference.
 */
@interface R4View : UIView

@property (strong, nonatomic, readonly) R4Scene *scene;
@property (assign, nonatomic, getter = isPaused) BOOL paused;
@property (assign, nonatomic) BOOL showFPS;
@property (assign, nonatomic) NSInteger frameInterval;

- (void)presentScene:(R4Scene *)scene;

/*!
 Converts a point from scene coordinates to view coordinates.
 
 @param point Point in scene coordinate system.
 @param scene A scene.
 @return The same point in the view’s coordinate system.
 
 @discussion Converts a 3D point from 3D scene coordinate system to 2D point in 2D view coordinate system (bounds).
 */
- (CGPoint)convertPoint:(GLKVector3)point fromScene:(R4Scene *)scene;

/*!
 Converts a point from view space (bounds) into a ray in scene space.
 
 @param point Point in view space.
 @param scene A scene.
 @return A ray in scene space.
 
 @discussion A point on 2D projection of the scene corresponds to a ray in scene space that intersects camera's near and far clip planes.
 */
- (R4Ray)convertPoint:(CGPoint)point toScene:(R4Scene *)scene;


// SpriteKit methods that are not implemented
//@property (assign, nonatomic) BOOL showDrawCount;
//@property (assign, nonatomic) BOOL showNodeCount;
//@property (assign, nonatomic) BOOL ignoresSiblingOrder;
//- (void)presentScene:(R4Scene *)scene transition:(R4Transition *)transition;
//- (R4Texture *)textureFromNode:(R4Node *)node;

@end
