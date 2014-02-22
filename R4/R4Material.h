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

/*!
 R4Material encapsulates all information on how to render objects (ones that conform to R4Drawable protocol).
 
 @discussion To be more specific, "description" on how to render something is specified by an R4Technique. Each R4Material can have more then one technique, but only one of them will be used to render an object - the optimal technique. Usually, material will have only one technique and that one will be the optimal, but you're able to specify more techniques with different levels of complexity, for example a simple one for iPhone 4 and a more complex one for iPhone 5 and later.
 @discussion The concept of techniques is in future intended to be extended to allow different techniques for different levels of detail.
 */

@interface R4Material : NSObject {
@public
  GLKVector4 _ambientColor;
  GLKVector4 _diffuseColor;
  GLKVector4 _specularColor;
  GLfloat _shininess;
}

@property (nonatomic, strong) NSMutableArray *techniques;

@property (nonatomic, assign) GLKVector4 ambientColor;
@property (nonatomic, assign) GLKVector4 diffuseColor;
@property (nonatomic, assign) GLKVector4 specularColor;
@property (nonatomic, assign) GLfloat shininess;

- (instancetype)init;
- (instancetype)initWithTechniques:(NSArray *)techniques;
+ (R4Material *)materialWithTechnique:(R4Technique *)technique;

/*!
 Creates a material with one technique that contains one R4PlanePass, basic texturing pass without lighting support.
 */
+ (R4Material *)planeMaterial;

/*!
 Creates a material with one technique that contains one R4ADSPass, basic texturing and Ambient-Diffuse-Specular lighting pass.
 */
+ (R4Material *)ADSMaterial;

- (R4Technique *)optimalTechnique;
- (R4Technique *)firstTechnique;
- (R4Technique *)techniqueAtIndex:(NSUInteger)index;

@end
