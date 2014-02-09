//
//  R4Pass.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"
#import "R4DrawState.h"
#import "R4Texture.h"
#import "R4TextureUnit.h"
#import "R4ProgramManager.h"

@class R4Shader, R4Program, R4TextureUnit, R4DrawState;


/*!
 R4Pass specifies all informations required to perform a draw operation. It manages vertex and fragment shaders, blending modes, depth writing and testing, face culling, textures, etc.
 
 @discussion If you're implementing a custom pass and you have to configure shader parameters (uniforms), you must subclass this class and override prepareToDraw: method in which you do your custom preparation for the draw, like setting up uniforms.
 */
@interface R4Pass : NSObject

/*!
 Defines how current draw result should be blended to the output framebuffer.
 */
@property (nonatomic, assign) R4BlendMode sceneBlend;

/*!
 Defines whether the draw does lighting calculations.
 
 @discussion Enables you to access lights that affect current R4Drawable.
 */
@property (nonatomic, assign) BOOL lighting;

/*!
 Defines whether depth testing should be performed.
 */
@property (nonatomic, assign) BOOL depthTest;

/*!
 Defines whether current drawing pass shoud write depth information to the framebuffer.
 */
@property (nonatomic, assign) BOOL depthWrite;

/*!
 Defines font-facing and back-facing polygons.
 */
@property (nonatomic, assign) R4FrontFace frontFace;

/*!
 Defines whether some polygons should be culled.
 */
@property (nonatomic, assign) R4CullFace cullFace;

/*!
 Defines number of times geometry should be drawn.
 
 @discussion Method prepareForIteration:drawState: will be called prior to each iteration.
 */
@property (nonatomic, assign) NSUInteger numberOfIterations;

/*!
 Defines whether the pass should be exectued per each light.
 
 @discussion Enables you to perform drawing separately for each light that affects object. If you set this to YES, only one iteration will be done (numberOfIterations will be ignored).
 */
@property (nonatomic, assign) BOOL iteratePerLight;

/*!
 An array of texture units.
 
 @discussion Prior to drawing, each texture unit will be bound to the current OpenGL context in order specified by this array. First unit will be bound to GL_TEXTURE0, second to GL_TEXTURE0+1, etc. Texture will be bound to corresponding units.
 */
@property (nonatomic, strong) NSMutableArray *textureUnits;

/*!
 Vertex shader to use for drawing.
 
 @warning Changing this might cause program to be re-linked (when not cached).
 */
@property (nonatomic, strong) R4Shader *vertexShader;

/*!
 Fragment shader to use for drawing.
 
 @warning Changing this might cause program to be re-linked (when not cached).
 */
@property (nonatomic, strong) R4Shader *fragmentShader;

/*!
 Program linked from configured vertex and fragment shaders. Automatically created when accessed for the first time. (read-only).
 */
@property (nonatomic, readonly) R4Program *program;

- (instancetype)init;
+ (instancetype)pass;

- (void)addTextureUnit:(R4TextureUnit *)textureUnit;
- (R4TextureUnit *)firstTextureUnit;
- (R4TextureUnit *)textureUnitAtIndex:(NSUInteger)index;

/*!
 Called by the renderer prior to drawing.
 
 @discussion Pass should configure OpenGL state common to all iterations, e.g. configure shaders' uniforms.
 */
- (void)prepareForDrawing:(R4DrawState *)drawState;

/*!
 Called by the renderer prior to each drawing iteration.
 
 @param iteration Iteration number. By default goes from 0 to numberOfIterations - 1. If you have set iteratePerLight property to YES, this will correspond to the index of currently bound light to the drawState.
 
 @discussion Here is your last chance to configure OpenGL state, e.g. configure shaders' uniforms that depend on iteration or light number.
 */
- (void)prepareForIteration:(NSUInteger)iteration drawState:(R4DrawState *)drawState;

@end
