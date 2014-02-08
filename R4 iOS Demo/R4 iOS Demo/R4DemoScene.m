//
//  R4DemoScene.m
//  R4 iOS Demo
//
//  Created by Srđan Rašić on 08/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4DemoScene.h"

@interface MovableEntityNode : R4EntityNode @end
@interface MovableEmitterNode : R4EmitterNode @end


@interface MyScene : R4Scene
@property (assign, nonatomic) NSTimeInterval timeOfLastUpdate;
@end

@implementation R4DemoScene

- (void)didMoveToView:(R4View *)view
{
  self.userInteractionEnabled = YES;
  self.name = @"mainScene";
  
  /* Floor */
  R4EntityNode *floor = [R4EntityNode entityWithMesh:[R4Mesh plainWithSize:CGSizeMake(15, 15)]];
  floor.orientation = GLKQuaternionMakeWithAngleAndAxis(-M_PI_2, 1, 0, 0);
  floor.name = @"floor";
  [floor.material.firstTechnique.firstPass addTextureUnit:[R4TextureUnit textureUnitWithTexture:[R4Texture textureWithImageNamed:@"floor.png"]]];
  [self addChild:floor];
  
  /* Stacy character */
  R4EntityNode *stacy = [MovableEntityNode entityWithMesh:[R4Mesh OBJMeshNamed:@"stacy.obj" normalize:YES center:NO]];
  stacy.name = @"stacy";
  stacy.userInteractionEnabled = YES;
  stacy.position = GLKVector3Make(0, 0, 4);
  [self addChild:stacy];
  
#if 1
  /* Make some clones of Stacy */
  NSInteger copies = 10;
  for (int i = 0; i < copies; i++) {
    R4EntityNode *c2 = [stacy copy];
    c2.name = @"stacy clone";
    c2.position = GLKVector3Make(-sinf(2 * M_PI / copies * i) * 2, 0, cosf(2 * M_PI / copies * i) * 2);
    CGFloat duration = 0.5 + (arc4random() % 100) / 50.0;
    [c2 runAction:[R4Action repeatActionForever:[R4Action sequence:@[[R4Action scaleTo:GLKVector3Make(1, 1, 1) duration:duration], [R4Action scaleTo:GLKVector3Make(1, .5, 1) duration:duration]]]]];
    [self addChild:c2];
  }
#endif
  
  /* Create a box */
  R4EntityNode *mp = [MovableEntityNode entityWithMesh:[R4Mesh boxWithSize:GLKVector3Make(1, 1, 1)]];
  mp.userInteractionEnabled = YES;
  [self addChild:mp];
  
  /* Put fire on the box */
  R4EmitterNode *fire = [[MovableEmitterNode alloc] initWithSKEmitterSKSFileNamed:@"FireParticle"];
  fire.particleTexture = [R4Texture textureWithImageNamed:@"flame.png"];
  fire.position = GLKVector3Make(0, .5, 0);
  fire.name = @"fire";
  [mp addChild:fire];
  
  /* One more particle emitter */
  R4EmitterNode *smoke = [[MovableEmitterNode alloc] initWithSKEmitterSKSFileNamed:@"SmokeParticle"];
  smoke.particleTexture = [R4Texture textureWithImageNamed:@"spark.png"];
  smoke.position = GLKVector3Make(-2, 0, -2);
  smoke.userInteractionEnabled = YES;
  smoke.name = @"smoke";
  [self addChild:smoke];
  
  /* Move camera */
  self.currentCamera.position = GLKVector3Make(-2, 2, 3);
  //self.currentCamera.targetNode = stacy;
  self.currentCamera.name = @"Camera";
  
  
#if 1
  R4LightNode *light = [R4LightNode pointLightAtPosition:GLKVector3Make(0, 2, 2)];
  light.constantAttenuation = 0;
  light.linearAttenuation = 1;
  [self addChild:light];
#endif
}

- (void)update:(NSTimeInterval)currentTime
{
  /* Circle with camera */
  self.currentCamera.position = GLKVector3Make(-sin(currentTime) * 5, 2, cos(currentTime) * 5);
}

@end


@implementation MovableEntityNode

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  AudioServicesPlaySystemSound (1104);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.position = [[touches anyObject] locationInNode:self.parent onPlain:GLKVector3Make(0, 1, 0)];
}

@end


@implementation MovableEmitterNode

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.position = [[touches anyObject] locationInNode:self.parent onPlain:GLKVector3Make(0, 1, 0)];
}

@end