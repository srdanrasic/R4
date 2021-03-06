//
//  R4Drawable.h
//  R4
//
//  Created by Srđan Rašić on 26/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import <Foundation/Foundation.h>

@class R4Material;

/*!
 Protocol that defines interface for drawable scene nodes.
 
 Any R4Node that implements this protocol and is part of the scene is processed by the renderer. That means that you can use this protocol to make drawable nodes with custom drawing code.
 */
@protocol R4Drawable <NSObject>

@required

/*!
 Material used to render the node.
 */
@property (nonatomic, readonly) R4Material *material;

/*!
 Indicated whether rendered should render bounding volume of the node. Default is NO.
 
 @discussion This feature should be used only for debug purpose.
 */
@property (nonatomic, assign) BOOL showBoundingVolume;


/*!
 Should prepare for drawing.
 
 @discussion Called by the Renderer prior to drawing. Object should prepare itself for the drawing - e.g. bind any buffers or vertex arrays to the current OpenGL context.
 */
- (void)prepareToDraw;

/*!
 Should draw the object to the current OpenGL context.
 
 @discussion Called by the Renderer. May be called multiple times, for example if multipass rendering is in progress.
 */
- (void)draw;

@end