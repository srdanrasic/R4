//
//  R4Material.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"
#import "R4Technique.h"
#import "R4Pass.h"
#import "R4TextureUnit.h"

@interface R4Material : NSObject

@property (nonatomic, strong) NSMutableArray *techniques;

@property (nonatomic, assign) GLKVector4 ambientColor;
@property (nonatomic, assign) GLKVector4 diffuseColor;
@property (nonatomic, assign) GLKVector4 specularColor;
@property (nonatomic, assign) GLfloat shininess;

- (instancetype)init;
- (instancetype)initWithTechniques:(NSArray *)techniques;
- (R4Technique *)optimalTechnique;
- (R4Technique *)firstTechnique;
- (R4Technique *)techniqueAtIndex:(NSUInteger)index;

@end
