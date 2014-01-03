//
//  R4EmitterNode.m
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4EmitterNode_Private.h"

@interface R4EmitterNode () {
  GLuint particleAttributesVertexBuffer;
  NSInteger maxParticeCount;
}
@property (nonatomic, assign) NSTimeInterval timeOfLastUpdate;
@property (nonatomic, assign) NSTimeInterval previousDT;
@end

@implementation R4EmitterNode

- (instancetype)init
{
  return [self initWithSKEmitterNode:[[SKEmitterNode alloc] init]];
}

- (instancetype)initWithSKEmitterNode:(SKEmitterNode *)skEmitterNode
{
  self = [super init];
  if (self) {
    //self.particleTexture = skEmitterNode.particleTexture;
    
    self.particleBlendMode = skEmitterNode.particleBlendMode;
    
    self.particleColor = skEmitterNode.particleColor;
    
    self.particleColorRedRange = skEmitterNode.particleColorRedRange;
    self.particleColorGreenRange = skEmitterNode.particleColorGreenRange;
    self.particleColorBlueRange = skEmitterNode.particleColorBlueRange;
    self.particleColorAlphaRange = skEmitterNode.particleColorAlphaRange;
    
    self.particleColorRedSpeed = skEmitterNode.particleColorRedSpeed;
    self.particleColorGreenSpeed = skEmitterNode.particleColorGreenSpeed;
    self.particleColorBlueSpeed = skEmitterNode.particleColorBlueSpeed;
    self.particleColorAlphaSpeed = skEmitterNode.particleColorAlphaSpeed;
    
    self.particleColorSequence = skEmitterNode.particleColorSequence;
    
    self.particleColorBlendFactor = skEmitterNode.particleColorBlendFactor;
    self.particleColorBlendFactorRange = skEmitterNode.particleColorBlendFactorRange;
    self.particleColorBlendFactorSpeed = skEmitterNode.particleColorBlendFactorSpeed;
    
    self.particleColorBlendFactorSequence = skEmitterNode.particleColorBlendFactorSequence;
    
    self.particlePosition = GLKVector3Make(skEmitterNode.particlePosition.x, skEmitterNode.particlePosition.y, 0);
    self.particlePositionRange = GLKVector3Make(skEmitterNode.particlePositionRange.dx, skEmitterNode.particlePositionRange.dy, 0);
    
    self.particleSpeed = skEmitterNode.particleSpeed;
    self.particleSpeedRange = skEmitterNode.particleSpeedRange;
    
    //self.emissionAngle = skEmitterNode.emissionAngle;
    self.emissionAxis = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(skEmitterNode.emissionAngle / 180.0 * M_PI, 0, 0, -1),
                                                   GLKVector3Make(0, 1, 0));
    
    self.emissionAxisRange = GLKVector3Make(skEmitterNode.emissionAngleRange / 360.0 - 0.5,
                                            skEmitterNode.emissionAngleRange / 360.0 - 0.5,
                                            skEmitterNode.emissionAngleRange / 360.0 - 0.5);
    
    self.xAcceleration = skEmitterNode.xAcceleration;
    self.yAcceleration = skEmitterNode.yAcceleration;
    self.zAcceleration = 0;

    self.particleBirthRate = skEmitterNode.particleBirthRate;
    self.numParticlesToEmit = skEmitterNode.numParticlesToEmit;
    
    self.particleLifetime = skEmitterNode.particleLifetime;
    self.particleLifetimeRange = skEmitterNode.particleLifetimeRange;
    
    self.particleRotation = skEmitterNode.particleRotation;
    self.particleRotationAxis = GLKVector3Make(0, 1, 0);
    self.particleRotationRange = skEmitterNode.particleRotationRange;
    self.particleRotationAxisRange = GLKVector3Make(0, 1, 0);
    
    self.particleRotationSpeed = skEmitterNode.particleRotationSpeed;
    
    self.particleSize = skEmitterNode.particleSize;
    
    self.particleScale = skEmitterNode.particleScale;
    self.particleScaleRange = skEmitterNode.particleScaleRange;
    self.particleScaleSpeed = skEmitterNode.particleScaleSpeed;
    
    self.particleScaleSequence = skEmitterNode.particleScaleSequence;
    
    self.particleAlpha = skEmitterNode.particleAlpha;
    self.particleAlphaRange = skEmitterNode.particleAlphaRange;
    self.particleAlphaSpeed = skEmitterNode.particleAlphaSpeed;
    self.particleAlphaSequence = skEmitterNode.particleAlphaSequence;

    [self prepareForDrawing];
  }
  return self;
}

- (instancetype)initWithSKEmitterSKSFileNamed:(NSString *)filename
{
  SKEmitterNode *skEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"sks"]];
  return [self initWithSKEmitterNode:skEmitterNode];
}

- (void)dealloc
{
  free(self.particleAttributes);
}

- (void)prepareForDrawing
{
  maxParticeCount = (self.particleLifetime + self.particleLifetimeRange) * self.particleBirthRate;
  
  if (self.numParticlesToEmit != 0) {
    maxParticeCount = MIN(maxParticeCount, self.numParticlesToEmit);
  }
  
  self.particleCount = 0;

  glGenBuffers(1, &particleAttributesVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, particleAttributesVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, maxParticeCount * sizeof(R4ParticleAttributes), NULL, GL_DYNAMIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)resetSimulation
{
  self.timeOfLastUpdate = CACurrentMediaTime();
  self.previousDT = 0.0;
}

- (R4ParticleAttributes *)mapParticleAttributesVertexBufferData
{
  glBindBuffer(GL_ARRAY_BUFFER, particleAttributesVertexBuffer);
  return (R4ParticleAttributes *)glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, maxParticeCount * sizeof(R4ParticleAttributes), GL_MAP_READ_BIT_EXT);
}

- (void)updateAtTime:(NSTimeInterval)time
{
  NSTimeInterval dt = time - self.timeOfLastUpdate;

  /* First update existing particles */
  for (unsigned idx = 0; idx < self.particleCount;) {
    R4ParticleAttributes *p = &self.particleAttributes[idx];
    
    if (p->timeToLive > 0.0) {
      CGFloat scale = self.particleScaleSpeed * dt;
      p->MVM = GLKMatrix4Translate(p->MVM, p->direction.x * dt, p->direction.y * dt, p->direction.z * dt);
      p->MVM = GLKMatrix4Scale(p->MVM, scale, scale, scale);
      p->MVM = GLKMatrix4RotateWithVector3(p->MVM, self.particleRotation, self.particleRotationAxis);
      
      GLKVector4 colorSpeed = GLKVector4Make(self.particleColorRedSpeed, self.particleColorGreenSpeed,
                                             self.particleColorBlueSpeed, self.particleColorAlphaSpeed);
      p->color = GLKVector4Add(p->color, GLKVector4MultiplyScalar(colorSpeed, dt));
      
      p->alpha += self.particleAlphaSpeed;
      p->colorBlendFactor += self.particleColorBlendFactorSpeed;
      p->timeToLive -= dt;
      idx++;
    } else {
      self.particleCount -= 1;
      if (idx != self.particleCount) {
        self.particleAttributes[idx] = self.particleAttributes[self.particleCount];
      }
    }
  }
  
  
  /* Then, emit new particles */
  NSInteger particles_to_emit = (self.previousDT + dt) * self.particleBirthRate;   // dt [ms]
  
  if (particles_to_emit == 0) {
    self.previousDT += dt;
  } else {
    self.previousDT = 0.0;
  }
  
  for (unsigned i = 0; i < particles_to_emit; i++) {
    R4ParticleAttributes *p = &self.particleAttributes[self.particleCount++];
    
    /* Initialise particle */
    p->timeToLive = p->lifetime = self.particleLifetime + self.particleLifetimeRange * randCGFloat(-1, 1);
    
    GLKVector3 position = GLKVector3Add(self.particlePosition, GLKVector3Multiply(self.particlePositionRange, randGLKVector3(-1, 1)));
    p->MVM = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
  
    p->direction = GLKVector3Add(self.emissionAxis, GLKVector3Multiply(self.emissionAxisRange, randGLKVector3(-1, 1)));
    
    CGFloat components[4];
    [self.particleColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    GLKVector4 particleColor = GLKVector4MakeWithArray(components);
    GLKVector4 particleColorRange = GLKVector4Make(self.particleColorRedRange, self.particleColorGreenRange,
                                                   self.particleColorBlueRange, self.particleColorAlphaRange);
    p->color = GLKVector4Add(particleColor, GLKVector4Multiply(particleColorRange, randGLKVector4(0, 1)));
    
    p->alpha = self.particleAlpha + self.particleAlphaRange * randCGFloat(-1, 1);
    p->colorBlendFactor = self.particleColorBlendFactor + self.particleColorBlendFactorRange * randCGFloat(-1, 1);
  }
  
  self.timeOfLastUpdate = time;
}

@end
