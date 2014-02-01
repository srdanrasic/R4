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

@interface R4Pass : NSObject

@property (nonatomic, assign) R4BlendMode sceneBlend;
@property (nonatomic, assign) BOOL lighting;
@property (nonatomic, assign) BOOL depthTest;
@property (nonatomic, assign) BOOL depthWrite;
@property (nonatomic, assign) R4FrontFace frontFace;
@property (nonatomic, assign) R4CullFace cullFace;
@property (nonatomic, strong) NSMutableArray *textureUnits;

@property (nonatomic, strong) R4Shader *vertexShader;
@property (nonatomic, strong) R4Shader *fragmentShader;
@property (nonatomic, readonly) R4Program *program;

- (instancetype)init;
+ (instancetype)pass;

- (void)addTextureUnit:(R4TextureUnit *)textureUnit;
- (R4TextureUnit *)firstTextureUnit;
- (R4TextureUnit *)textureUnitAtIndex:(NSUInteger)index;

- (void)prepareToDraw:(R4DrawState *)drawState;

@end
