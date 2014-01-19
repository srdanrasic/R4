//
//  R4Pass.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Shader, R4Program, R4TextureUnit;

@interface R4Pass : NSObject

@property (nonatomic, assign) R4BlendMode sceneBlend;
@property (nonatomic, assign) BOOL lighting;
@property (nonatomic, assign) BOOL depthTest;
@property (nonatomic, assign) BOOL depthWrite;
@property (nonatomic, strong) NSMutableArray *textureUnits;

@property (nonatomic, strong) R4Shader *vertexShader;
@property (nonatomic, strong) R4Shader *fragmentShader;
@property (nonatomic, strong, readonly) R4Program *program;

- (instancetype)init;
- (void)addTextureUnit:(R4TextureUnit *)textureUnit;
- (R4TextureUnit *)firstTextureUnit;
- (R4TextureUnit *)textureUnitAtIndex:(NSUInteger)index;

- (void)prepareToDraw;

@end
