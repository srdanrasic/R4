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
  
  R4Node *stacyBase = [R4Node node];
  stacyBase.name = @"stacyBase";
  stacyBase.userInteractionEnabled = YES;
  
  [self addChild:stacyBase];
  
  R4EntityNode *stacy = [MovableEntityNode entityWithMesh:[R4Mesh OBJMeshNamed:@"stacy.obj" normalize:YES center:NO]];
  stacy.name = @"stacy";
  stacy.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, -1);
  stacy.scale = GLKVector3Make(1, 1, 1);
  stacy.speed = 1;
  //stacy.blendMode = R4BlendModeAlpha;
  stacy.userInteractionEnabled = YES;
  [stacyBase addChild:stacy];
  
#if 1
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      R4EntityNode *c2 = [stacy copy];
      c2.position = GLKVector3Make(-2 + i, 0, 1-j);
      CGFloat duration = 0.5 + (arc4random() % 100) / 50.0;
      [c2 runAction:[R4Action repeatActionForever:[R4Action sequence:@[
                                                                       [R4Action scaleTo:GLKVector3Make(1, 1, 1) duration:duration],
                                                                       [R4Action scaleTo:GLKVector3Make(1, .5, 1) duration:duration]
                                                                       ]]]];
      [stacyBase addChild:c2];
    }
  }
#endif
  
  [stacy removeAllActions];
  stacy.position = GLKVector3Make(0, 0, 4);
  
  R4EntityNode *base = [R4EntityNode entityWithMesh:[R4Mesh boxWithSize:GLKVector3Make(15, .01, 15)]];
  base.name = @"base";
  base.userInteractionEnabled = YES;
  base.position = GLKVector3Make(0, 0, 0);
  ///spaceship2.orientation = GLKQuaternionMakeWithAngleAndAxis(0.6, 0, 1, -1);
  //base.highlightColor = [UIColor colorWithRed:0.1 green:0.05 blue:0.1 alpha:1.0];
  [self addChild:base];
  
#if 1
  R4LightNode *light = [R4LightNode pointLightAtPosition:GLKVector3Make(0, 2, 2)];
  light.constantAttenuation = 0;
  light.linearAttenuation = 1;
  [self addChild:light];
#endif
  
  self.currentCamera.position = GLKVector3Make(-2, 2, 3);
  //self.currentCamera.targetNode = stacy;
  self.currentCamera.name = @"Camera";
  //[stacy addChild:self.currentCamera];
  
  R4EmitterNode *stars = [[R4EmitterNode alloc] initWithSKEmitterSKSFileNamed:@"StarParticle"];
  stars.position = GLKVector3Make(0, 4, 0);
  stars.particlePositionRange = GLKVector3Make(10, 0, 10);
  stars.name = @"stars";
  [stars advanceSimulationTime:8];
  [self addChild:stars];
  
  R4EmitterNode *fire = [[MovableEmitterNode alloc] initWithSKEmitterSKSFileNamed:@"FireParticle"];
  fire.position = GLKVector3Make(1, 0, 0);
  fire.name = @"fire";
  fire.userInteractionEnabled = YES;
  [base addChild:fire];
  
  R4EmitterNode *sparks = [[MovableEmitterNode alloc] initWithSKEmitterSKSFileNamed:@"SparkParticle"];
  sparks.position = GLKVector3Make(-1, 0, 0);
  sparks.userInteractionEnabled = YES;
  sparks.name = @"sparks";
  [self addChild:sparks];
  
  R4EntityNode *mp = [MovableEntityNode entityWithMesh:[R4Mesh boxWithSize:GLKVector3Make(1, 5, 1)]];
  mp.userInteractionEnabled = YES;
  [self addChild:mp];
}

- (void)update:(NSTimeInterval)currentTime
{
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
