//
//  R4EmitterNode.h
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"
#import "R4Drawable.h"

/*!
 A R4EmitterNode object is a node that automatically creates and renders small particle sprites. 
 
 @discussion Class is designed to provide same functionality as SpriteKit's SKEmitterNode, just in 3D space. In fact, you can instantiate R4EmitterNode object from SKEmitterNode object and all conversion to 3D space is done automatically. That means that you can use Xcode's Particle editor to create particle effects, save them in .sks files and instantiate R4EmitterNode object from them.
 
 @discussion During conversion, emitter's position, speed and acceleration values are divided by 100.0 to compensate for differences between spaces. particlePosition.z and zAcceleration are set to 0. emissionAngle is converted to emissionAxis - a vector that defines emission direction - vector (1, 0, 0) rotated by emissionAngle around positive z-axis.
 */
@interface R4EmitterNode : R4Node <R4Drawable>

@property (nonatomic, retain) SKTexture *particleTexture;

@property (nonatomic) R4BlendMode particleBlendMode;

@property (nonatomic, retain) UIColor *particleColor;

@property (nonatomic) CGFloat particleColorRedRange;
@property (nonatomic) CGFloat particleColorGreenRange;
@property (nonatomic) CGFloat particleColorBlueRange;
@property (nonatomic) CGFloat particleColorAlphaRange;

@property (nonatomic) CGFloat particleColorRedSpeed;
@property (nonatomic) CGFloat particleColorGreenSpeed;
@property (nonatomic) CGFloat particleColorBlueSpeed;
@property (nonatomic) CGFloat particleColorAlphaSpeed;

@property (nonatomic, retain) SKKeyframeSequence *particleColorSequence;

@property (nonatomic) CGFloat particleColorBlendFactor;
@property (nonatomic) CGFloat particleColorBlendFactorRange;
@property (nonatomic) CGFloat particleColorBlendFactorSpeed;

@property (nonatomic, retain) SKKeyframeSequence *particleColorBlendFactorSequence;

@property (nonatomic) GLKVector3 particlePosition;
@property (nonatomic) GLKVector3 particlePositionRange;

@property (nonatomic) CGFloat particleSpeed;
@property (nonatomic) CGFloat particleSpeedRange;

//@property (nonatomic) CGFloat emissionAngle;
@property (nonatomic) GLKVector3 emissionAxis;
@property (nonatomic) GLKVector3 emissionAngleRange;

@property (nonatomic) CGFloat xAcceleration;
@property (nonatomic) CGFloat yAcceleration;
@property (nonatomic) CGFloat zAcceleration;

@property (nonatomic) CGFloat particleBirthRate;
@property (nonatomic) NSUInteger numParticlesToEmit;

@property (nonatomic) CGFloat particleLifetime;
@property (nonatomic) CGFloat particleLifetimeRange;

@property (nonatomic) CGFloat particleRotation;
@property (nonatomic) GLKVector3 particleRotationAxis;
@property (nonatomic) CGFloat particleRotationRange;
@property (nonatomic) GLKVector3 particleRotationAxisRange;

@property (nonatomic) CGFloat particleRotationSpeed;

@property (nonatomic) CGSize particleSize;

@property (nonatomic) CGFloat particleScale;
@property (nonatomic) CGFloat particleScaleRange;
@property (nonatomic) CGFloat particleScaleSpeed;

@property (nonatomic, retain) SKKeyframeSequence *particleScaleSequence;

@property (nonatomic) CGFloat particleAlpha;
@property (nonatomic) CGFloat particleAlphaRange;
@property (nonatomic) CGFloat particleAlphaSpeed;
@property (nonatomic, retain) SKKeyframeSequence *particleAlphaSequence;

//@property (nonatomic, copy) SKAction *particleAction;
//@property (nonatomic, weak) SKNode *targetNode;

- (instancetype)init;
- (instancetype)initWithSKEmitterNode:(SKEmitterNode *)skEmitterNode;
- (instancetype)initWithSKEmitterSKSFileNamed:(NSString *)filename;

- (void)advanceSimulationTime:(NSTimeInterval)sec;
- (void)resetSimulation;

@end
