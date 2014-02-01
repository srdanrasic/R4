//
//  R4ProgramManager.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"
#import "R4Shader.h"

@class R4Program;

@interface R4ProgramManager : NSObject

+ (R4ProgramManager *)shared;

- (R4Shader *)loadVertexShaderNamed:(NSString *)name attributeMapping:(NSDictionary *)attributeMapping;
- (R4Shader *)loadFragmentShaderNamed:(NSString *)name attributeMapping:(NSDictionary *)attributeMapping;

- (R4Program *)programWithVertexShader:(R4Shader *)vertexShader fragmentShader:(R4Shader *)fragmentShader;
- (R4Program *)programWithVertexShaderName:(NSString *)vertexShaderName fragmentShaderName:(NSString *)fragmentShaderName;

@end
