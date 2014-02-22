//
//  R4DemoScene.m
//  R4 iOS Demo
//
//  Created by Srđan Rašić on 08/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4DemoScene.h"
#import <AudioToolbox/AudioToolbox.h>

// Lets subclass R4EntityNode to make movable nodes
@interface MovableEntityNode : R4EntityNode @end


@implementation R4DemoScene

- (void)didMoveToView:(R4View *)view
{
  // Child nodes can have user interation enabled only if parent also has it enabled
  self.userInteractionEnabled = YES;
  
  // Floor template plane
  R4EntityNode *floor = [R4EntityNode entityWithMesh:[R4Mesh planeWithSize:CGSizeMake(1, 1)]];
  
  // By default, plane is on XY axis so we need to rotate it to xz axis
  floor.orientation = GLKQuaternionMakeWithAngleAndAxis(-M_PI_2, 1, 0, 0);
  
  // Set texture
  [floor.material.firstTechnique.firstPass addTextureUnit:[R4TextureUnit textureUnitWithTexture:[R4Texture textureWithImageNamed:@"floor.png"]]];
  
  // Make it shiny
  floor.material.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
  floor.material.shininess = 2;
  
  // Build floor out of those planes
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 10; j++) {
      R4Node *b = [floor copy];
      b.position = GLKVector3Make(i - 5, 0, j - 5);
      [self addChild:b];
    }
  }
  
  // Create movable box (see how subclass is implemented on bottom of this file)
  R4EntityNode *box = [MovableEntityNode entityWithMesh:[R4Mesh boxWithSize:GLKVector3Make(0.5, 2, 0.5)]];
  
  // Lets change material to a simpler one - one that does not consider lights in the scene
  box.material = [R4Material planeMaterial];
  box.userInteractionEnabled = YES;
  
  // Make some clones in a circle
  NSInteger copies = 10;
  for (int i = 0; i < copies; i++) {
    R4EntityNode *c2 = [box copy];
    c2.position = GLKVector3Make(-sinf(2 * M_PI / copies * i) * 2, 0, cosf(2 * M_PI / copies * i) * 2);
    c2.orientation = GLKQuaternionMakeWithAngleAndAxis(2 * M_PI / copies * i, 0, -1, 0);
    
    // Lets make each clone run some action
    CGFloat duration = 0.5 + (arc4random() % 100) / 50.0;
    [c2 runAction:[R4Action repeatActionForever:[R4Action sequence:@[[R4Action scaleTo:GLKVector3Make(1, 1, 1) duration:duration], [R4Action scaleTo:GLKVector3Make(1, .5, 1) duration:duration]]]]];
    [self addChild:c2];
  }
  
  // Create a mesh node
  R4EntityNode *f16 = [R4EntityNode entityWithMesh:[R4Mesh OBJMeshNamed:@"f16.obj" normalize:YES center:NO]];
  f16.position = GLKVector3Make(0, 1, 0);
  [self addChild:f16];
  
  // Add some fire by loading SKS file
  R4EmitterNode *fire = [[R4EmitterNode alloc] initWithSKEmitterSKSFileNamed:@"FireParticle"];
  
  // Texture is not automatically loaded from SKS file, we must do it manually
  fire.particleTexture = [R4Texture textureWithImageNamed:@"flame.png"];
  fire.position = GLKVector3Make(0, 0, -.8f);
  
  // Emit particles in -z direction
  fire.emissionAxis = GLKVector3Make(0, 0, -1);
  [f16 addChild:fire];
  
  // Add light
  R4LightNode *light = [R4LightNode pointLightAtPosition:GLKVector3Make(0, 2, 0)];
  [self addChild:light];
}

- (void)update:(NSTimeInterval)currentTime
{
  // Make camera circle around scene
  self.currentCamera.position = GLKVector3Make(-sin(currentTime) * 5, 2, cos(currentTime) * 5);
}

@end


@implementation MovableEntityNode

// If node has userInteractionEnabled set to YES, these methods will
// get called when user taps on and moves node 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  AudioServicesPlaySystemSound (1104);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  // Get location where touch intersects y plane, in parent node coordinate system
  self.position = [[touches anyObject] locationInNode:self.parent onPlane:GLKVector3Make(0, 1, 0)];
}

@end
