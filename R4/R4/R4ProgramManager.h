//
//  R4ProgramManager.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"
#import "R4Shader.h"
#import "R4Program.h"

@class R4Program;

/*!
  R4ProgramManager ensures that there are never two identical shaders or programs in memory and provides a caching mechanism for shaders and programs.
 
 @discussion You should use this class to create shader objecta as it provides caching mechanism and ensures that there are never two identical shaders in memory.
 
 @warning Usually you don't create program objects by yourself. Program objects are created from R4Pass when you specify its vertex and fragment shader.
 */
@interface R4ProgramManager : NSObject

+ (R4ProgramManager *)shared;

- (R4Shader *)loadShaderNamed:(NSString *)name type:(R4ShaderType)type attributeMapping:(NSDictionary *)attributeMapping;

- (R4Program *)programWithVertexShader:(R4Shader *)vertexShader fragmentShader:(R4Shader *)fragmentShader;
- (R4Program *)programWithVertexShaderName:(NSString *)vertexShaderName fragmentShaderName:(NSString *)fragmentShaderName;

@end
