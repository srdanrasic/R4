//
//  R4EmitterNode.h
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"
#import "R4Drawable.h"

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
