//
//  R4EmitterNode.m
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4EmitterNode_Private.h"
#import "R4DrawableNode_private.h"

@interface R4EmitterNode ()
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
    
    self.particleSpeed = skEmitterNode.particleSpeed / 100.f;
    self.particleSpeedRange = skEmitterNode.particleSpeedRange / 100.f;
    
    //self.emissionAngle = skEmitterNode.emissionAngle;
    self.emissionAxis = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(skEmitterNode.emissionAngle / 180.0 * M_PI, 0, 0, -1),
                                                   GLKVector3Make(0, 1, 0));
    self.emissionAxis = GLKVector3Normalize(self.emissionAxis);
    
    self.emissionAxisRange = GLKVector3Make(skEmitterNode.emissionAngleRange / 360.0 - 0.5,
                                            skEmitterNode.emissionAngleRange / 360.0 - 0.5,
                                            skEmitterNode.emissionAngleRange / 360.0 - 0.5);
    
    self.xAcceleration = skEmitterNode.xAcceleration / 100.0;
    self.yAcceleration = skEmitterNode.yAcceleration / 100.0;
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

    [self commonInit];
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
  glDeleteBuffers(1, &particleAttributesVertexBuffer);
  free(self.particleAttributes);
}

- (void)commonInit
{
  maxParticeCount = (self.particleLifetime + self.particleLifetimeRange) * self.particleBirthRate;
  
  if (self.numParticlesToEmit != 0) {
    maxParticeCount = MIN(maxParticeCount, self.numParticlesToEmit);
  }
  
  self.particleCount = 0;
  
  self.particleDrawable = [R4PrimitiveNode boxWithSize:GLKVector3Make(.4, .4, .4)];

  glGenVertexArraysOES(1, &particleAttributesVertexArray);
  glGenBuffers(1, &particleAttributesVertexBuffer);
  
  glBindVertexArrayOES(particleAttributesVertexArray);
  
  glBindBuffer(GL_ARRAY_BUFFER, particleAttributesVertexBuffer);
  
  glEnableVertexAttribArray(R4VertexAttribMVM + 0);
  glEnableVertexAttribArray(R4VertexAttribMVM + 1);
  glEnableVertexAttribArray(R4VertexAttribMVM + 2);
  glEnableVertexAttribArray(R4VertexAttribMVM + 3);
  
  glVertexAttribPointer(R4VertexAttribMVM + 0, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 0));
  glVertexAttribPointer(R4VertexAttribMVM + 1, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 1));
  glVertexAttribPointer(R4VertexAttribMVM + 2, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 2));
  glVertexAttribPointer(R4VertexAttribMVM + 3, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 3));
  
  glVertexAttribDivisorEXT(R4VertexAttribMVM + 0, 1);
  glVertexAttribDivisorEXT(R4VertexAttribMVM + 1, 1);
  glVertexAttribDivisorEXT(R4VertexAttribMVM + 2, 1);
  glVertexAttribDivisorEXT(R4VertexAttribMVM + 3, 1);
  
  glEnableVertexAttribArray(R4VertexAttribColor);
  glVertexAttribPointer(R4VertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)offsetof(R4ParticleAttributes, color));
  glVertexAttribDivisorEXT(R4VertexAttribColor, 1);
  
  glEnableVertexAttribArray(R4VertexAttribAlpha);
  glVertexAttribPointer(R4VertexAttribAlpha, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)offsetof(R4ParticleAttributes, alpha));
  glVertexAttribDivisorEXT(R4VertexAttribAlpha, 1);

  glBindBuffer(GL_ARRAY_BUFFER, self.particleDrawable.drawableObject->vertexBuffer);
  
  glEnableVertexAttribArray(R4VertexAttribPosition);
  glVertexAttribPointer(R4VertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, (GLvoid*)0);
  
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArrayOES(0);
  
  self.particleAttributes = malloc(maxParticeCount * sizeof(R4ParticleAttributes));
  
  [self resetSimulation];
}

- (void)resetSimulation
{
  self.timeOfLastUpdate = CACurrentMediaTime();
  self.previousDT = 0.0;
}

- (void)updateAtTime:(NSTimeInterval)time
{
  NSTimeInterval dt = time - self.timeOfLastUpdate;
  if (dt > 1) {
    dt = 0.1;
  }
  NSLog(@"Particle count: %d", self.particleCount);
  /* First update existing particles */
  for (unsigned idx = 0; idx < self.particleCount;) {
    R4ParticleAttributes *p = &self.particleAttributes[idx];
    p->timeToLive -= dt;

    if (p->timeToLive > 0.0) {
      CGFloat time = 1.0f - p->timeToLive / p->lifetime;
      CGFloat age = p->lifetime - p->timeToLive;
      
      GLKVector3 position = GLKVector3Make(p->initialPosition.x + p->direction.x * p->speed * age + 0.5 * self.xAcceleration * age * age,
                                           p->initialPosition.y + p->direction.y * p->speed * age + 0.5 * self.yAcceleration * age * age,
                                           p->initialPosition.z + p->direction.z * p->speed * age + 0.5 * self.zAcceleration * age * age);
      
      CGFloat scale = p->initialScale + age * self.particleScaleSpeed;
      
      p->MVM = GLKMatrix4Scale(GLKMatrix4MakeTranslation(position.x, position.y, position.z), scale, scale, scale);
      
      
      //p->MVM = GLKMatrix4Scale(p->MVM, scale, scale, scale);
      //p->MVM = GLKMatrix4RotateWithVector3(p->MVM, self.particleRotation, self.particleRotationAxis);
      
      p->alpha = MIN(1, MAX(0, p->initialAlpha + age * self.particleAlphaSpeed));
      
      if (self.particleColorSequence) {
        CGFloat components[4];
        [[self.particleColorSequence sampleAtTime:time] getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
        p->color = GLKVector4MakeWithArray(components);
      } else {
        GLKVector4 colorSpeed = GLKVector4Make(self.particleColorRedSpeed, self.particleColorGreenSpeed,
                                               self.particleColorBlueSpeed, self.particleColorAlphaSpeed);
        p->color = GLKVector4Add(p->color, GLKVector4MultiplyScalar(colorSpeed, dt));
      }

      p->colorBlendFactor += self.particleColorBlendFactorSpeed;
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
    p->initialPosition = GLKVector3Add(self.particlePosition, GLKVector3Multiply(self.particlePositionRange, randGLKVector3(-1, 1)));
    p->initialScale = self.particleScale + self.particleScaleRange * randCGFloat(-1, 1);
    p->initialAlpha = self.particleAlpha + self.particleAlphaRange * randCGFloat(-1, 1);
    p->speed = self.particleSpeed + self.particleSpeedRange * randCGFloat(-1, 1);

    p->MVM = GLKMatrix4MakeTranslation(p->initialPosition.x, p->initialPosition.y, p->initialPosition.z);
    p->MVM = GLKMatrix4Scale(p->MVM, p->initialScale, p->initialScale, p->initialScale);
  
    p->direction = GLKVector3Add(self.emissionAxis, GLKVector3Multiply(self.emissionAxisRange, randGLKVector3(-1, 1)));
    
    CGFloat components[4];
    
    if (self.particleColorSequence) {
      [[self.particleColorSequence sampleAtTime:0] getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
      p->color = GLKVector4MakeWithArray(components);
    } else {
      [self.particleColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
      GLKVector4 particleColor = GLKVector4MakeWithArray(components);
      GLKVector4 particleColorRange = GLKVector4Make(self.particleColorRedRange, self.particleColorGreenRange,
                                                     self.particleColorBlueRange, self.particleColorAlphaRange);
      p->color = GLKVector4Add(particleColor, GLKVector4Multiply(particleColorRange, randGLKVector4(0, 1)));
    }
    
    p->alpha = self.particleAlpha + self.particleAlphaRange * randCGFloat(-1, 1);
    p->colorBlendFactor = self.particleColorBlendFactor + self.particleColorBlendFactorRange * randCGFloat(-1, 1);
  }
  
  self.timeOfLastUpdate = time;
}

@end
