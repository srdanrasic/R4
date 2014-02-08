//
//  R4EmitterNode.m
//  R4
//
//  Created by Srđan Rašić on 25/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4EmitterNodePrivate.h"
#import "R4Mesh.h"
#import "R4Material.h"
#import "R4ProgramManager.h"
#import "R4Shader.h"
#import "R4Texture.h"
#import "R4ScenePrivate.h"
#import "R4CameraNodePrivate.h"
#import "R4ParticlePass.h"

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
    
    self.particlePosition = GLKVector3Make(skEmitterNode.particlePosition.x / 100.f, skEmitterNode.particlePosition.y / 100.f, 0);
    self.particlePositionRange = GLKVector3Make(skEmitterNode.particlePositionRange.dx / 100.f, skEmitterNode.particlePositionRange.dy / 100.f, 0);
    
    self.particleSpeed = skEmitterNode.particleSpeed / 100.f;
    self.particleSpeedRange = skEmitterNode.particleSpeedRange / 100.f;
    
    self.emissionAxis = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(skEmitterNode.emissionAngle, 0, 0, 1), GLKVector3Make(1, 0, 0));
    self.emissionAngleRange = GLKVector3Make(skEmitterNode.emissionAngleRange, skEmitterNode.emissionAngleRange, skEmitterNode.emissionAngleRange);
    
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
  free(particleAttributes);
}

- (R4Box)boundingBox
{
  return R4BoxMake(GLKVector3Make(-.5f, -.5f, -.5f), GLKVector3Make(.5f, .5f, .5f));
}

- (void)setScene:(R4Scene *)scene
{
  if (scene) {
    [scene.particleEmitters addObject:self];
  } else {
    [scene.particleEmitters removeObject:self];
  }
  
  [super setScene:scene];
}

- (void)setEmissionAxis:(GLKVector3)emissionAxis
{
  _emissionAxis = GLKVector3Normalize(emissionAxis);
}

- (void)setParticleBlendMode:(R4BlendMode)particleBlendMode
{
  _particleBlendMode = particleBlendMode;
  material.firstTechnique.firstPass.sceneBlend = particleBlendMode;
}

- (R4Material *)material
{
  return material;    
}

- (void)commonInit
{
  maxParticeCount = (self.particleLifetime + self.particleLifetimeRange) * self.particleBirthRate;
  
  if (self.numParticlesToEmit != 0) {
    maxParticeCount = MIN(maxParticeCount, self.numParticlesToEmit);
  }
  
  particleCount = 0;
  particleMesh = [R4Mesh plainWithSize:CGSizeMake(1, 1)];

  R4ParticlePass *pass = [R4ParticlePass pass];
  pass.sceneBlend = self.particleBlendMode;
  material = [R4Material materialWithTechnique:[R4Technique techniqueWithPass:pass]];
  
  glGenVertexArraysOES(1, &particleAttributesVertexArray);
  glGenBuffers(1, &particleAttributesVertexBuffer);
  
  glBindVertexArrayOES(particleAttributesVertexArray);
  
  glBindBuffer(GL_ARRAY_BUFFER, particleAttributesVertexBuffer);
  
  glEnableVertexAttribArray(R4VertexAttributeModelMatrix + 0);
  glEnableVertexAttribArray(R4VertexAttributeModelMatrix + 1);
  glEnableVertexAttribArray(R4VertexAttributeModelMatrix + 2);
  glEnableVertexAttribArray(R4VertexAttributeModelMatrix + 3);
  
  glVertexAttribPointer(R4VertexAttributeModelMatrix + 0, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 0));
  glVertexAttribPointer(R4VertexAttributeModelMatrix + 1, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 1));
  glVertexAttribPointer(R4VertexAttributeModelMatrix + 2, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 2));
  glVertexAttribPointer(R4VertexAttributeModelMatrix + 3, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)(offsetof(R4ParticleAttributes, MVM) + sizeof(GLKVector4) * 3));
  
  glVertexAttribDivisorEXT(R4VertexAttributeModelMatrix + 0, 1);
  glVertexAttribDivisorEXT(R4VertexAttributeModelMatrix + 1, 1);
  glVertexAttribDivisorEXT(R4VertexAttributeModelMatrix + 2, 1);
  glVertexAttribDivisorEXT(R4VertexAttributeModelMatrix + 3, 1);
  
  glEnableVertexAttribArray(R4VertexAttributeColor);
  glVertexAttribPointer(R4VertexAttributeColor, 4, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)offsetof(R4ParticleAttributes, color));
  glVertexAttribDivisorEXT(R4VertexAttributeColor, 1);

  glEnableVertexAttribArray(R4VertexAttributeColorBlendFactor);
  glVertexAttribPointer(R4VertexAttributeColorBlendFactor, 1, GL_FLOAT, GL_FALSE, sizeof(R4ParticleAttributes), (GLvoid*)offsetof(R4ParticleAttributes, colorBlendFactor));
  glVertexAttribDivisorEXT(R4VertexAttributeColorBlendFactor, 1);

  glBindBuffer(GL_ARRAY_BUFFER, particleMesh->vertexBuffer);
  
  glEnableVertexAttribArray(R4VertexAttributePositionModelSpace);
  glVertexAttribPointer(R4VertexAttributePositionModelSpace, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, BUFFER_OFFSET(0));
  
  glEnableVertexAttribArray(R4VertexAttributeTexCoord0);
  glVertexAttribPointer(R4VertexAttributeTexCoord0, 2, GL_FLOAT, GL_FALSE,  sizeof(GLfloat) * 8, BUFFER_OFFSET(24));
  
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArrayOES(0);
  
  particleAttributes = malloc(maxParticeCount * sizeof(R4ParticleAttributes));
  
  [self resetSimulation];
}

- (void)resetSimulation
{
  self.timeOfLastUpdate = CACurrentMediaTime();
  self.previousDT = 0.0;
}

- (void)advanceSimulationTime:(NSTimeInterval)sec
{
  // TODO
}

- (void)updateAtTime:(NSTimeInterval)time
{
  NSTimeInterval dt = time - _timeOfLastUpdate;
    
  /* Update existing particles */
  GLKMatrix4 invR = GLKMatrix4Invert(self.scene.currentCamera.inversedTransform, NULL);
  GLKQuaternion q = GLKQuaternionMakeWithMatrix4(invR);
  CGFloat angle = GLKQuaternionAngle(q);
  GLKVector3 axis = GLKQuaternionAxis(q);
  
  for (unsigned idx = 0; idx < particleCount;) {
    R4ParticleAttributes *p = &particleAttributes[idx];
    p->timeToLive -= dt;

    if (p->timeToLive > 0.f) {
      CGFloat time = 1.0f - p->timeToLive / p->lifetime;
      CGFloat age = p->lifetime - p->timeToLive;
      
      GLKVector3 position = GLKVector3Make(p->initialPosition.x + p->direction.x * p->speed * age + 0.5 * _xAcceleration * age * age,
                                           p->initialPosition.y + p->direction.y * p->speed * age + 0.5 * _yAcceleration * age * age,
                                           p->initialPosition.z + p->direction.z * p->speed * age + 0.5 * _zAcceleration * age * age);
      
      CGFloat scale = MAX(0, p->initialScale + age * _particleScaleSpeed);
      
      p->MVM = GLKMatrix4Scale(GLKMatrix4MakeTranslation(position.x, position.y, position.z), scale, scale, scale);
      p->MVM = GLKMatrix4RotateWithVector3(p->MVM, angle, axis);
      
      //p->MVM = GLKMatrix4Scale(p->MVM, scale, scale, scale);
      //p->MVM = GLKMatrix4RotateWithVector3(p->MVM, self.particleRotation, self.particleRotationAxis);
      
      GLKVector4 particleColor;
      if (_particleColorSequence) {
        UIColor *color = [_particleColorSequence sampleAtTime:time];
        [color getRed:&particleColor.r green:&particleColor.g blue:&particleColor.b alpha:&particleColor.a];
        
      } else {
        GLKVector4 colorSpeed = GLKVector4Make(_particleColorRedSpeed, _particleColorGreenSpeed, _particleColorBlueSpeed, _particleColorAlphaSpeed);
        particleColor = GLKVector4Add(p->initialColor, GLKVector4MultiplyScalar(colorSpeed, age));
      }
      
      particleColor.a = MIN(1, MAX(0, particleColor.a + age * _particleAlphaSpeed));
      p->color = particleColor;
      
      // Let's kill forever hidden particles to improve performance
      if ((scale < 0.f && _particleScaleSpeed >= 0.f) || (particleColor.a < 0.001 && _particleColorAlphaSpeed * _particleAlphaSpeed <= 0.f)) {
        p->timeToLive = 0.f;
      }
      
      p->colorBlendFactor =  MIN(1, MAX(0, p->initialColorBlendFactor + _particleColorBlendFactorSpeed * age));
      
      idx++;
    } else {
      particleCount -= 1;
      if (idx != particleCount) {
        particleAttributes[idx] = particleAttributes[particleCount];
      }
    }
  }
  
  /* Emit new particles - should make this first!? */
  NSInteger particles_to_emit = (_previousDT + dt) * _particleBirthRate;   // dt [ms]
  
  if (particles_to_emit == 0) {
    _previousDT += dt;
  } else {
    _previousDT = 0.0;
  }
  
  GLKVector3 worldspacePosition = [self convertPoint:GLKVector3Make(0, 0, 0) toNode:self.scene];
  
  for (unsigned i = 0; i < particles_to_emit && particleCount < maxParticeCount - 1; i++) {
    R4ParticleAttributes *p = &particleAttributes[particleCount++];
    
    /* Initialise particle */
    p->timeToLive = p->lifetime = _particleLifetime + _particleLifetimeRange * randCGFloat(-1, 1);
    p->initialPosition = GLKVector3Add(worldspacePosition, GLKVector3Add(_particlePosition, GLKVector3Multiply(_particlePositionRange, randGLKVector3(-1, 1))));
    p->initialScale = _particleScale + _particleScaleRange * randCGFloat(-1, 1);
    p->initialColorBlendFactor = _particleColorBlendFactor + _particleColorBlendFactorRange * randCGFloat(-1, 1);
    p->speed = _particleSpeed + _particleSpeedRange * randCGFloat(-1, 1);

    p->MVM = GLKMatrix4MakeTranslation(p->initialPosition.x, p->initialPosition.y, p->initialPosition.z);
    p->MVM = GLKMatrix4Scale(p->MVM, p->initialScale, p->initialScale, p->initialScale);
  
    //CGFloat range = _emissionAngleRange / 360.0;
    p->direction = _emissionAxis;// GLKVector3Add(_emissionAxis, GLKVector3Multiply(GLKVector3Make(range, range, range), randGLKVector3(-1, 1)));
    
    GLKVector3 emissionAxis = _emissionAxis;
    emissionAxis = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(_emissionAngleRange.x * randCGFloat(0, 1), 1, 0, 0), emissionAxis);
    emissionAxis = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(_emissionAngleRange.y * randCGFloat(0, 1), 0, 1, 0), emissionAxis);
    emissionAxis = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(_emissionAngleRange.z * randCGFloat(0, 1), 0, 0, 1), emissionAxis);
    p->direction = emissionAxis;
    
    if (!_particleColorSequence) {
      GLKVector4 color;
      [_particleColor getRed:&color.r green:&color.g blue:&color.b alpha:&color.a];
      GLKVector4 particleColorRange = GLKVector4Make(_particleColorRedRange, _particleColorGreenRange,
                                                     _particleColorBlueRange, _particleColorAlphaRange);
      p->initialColor = GLKVector4Add(color, GLKVector4Multiply(particleColorRange, randGLKVector4(0, 1)));
    }
    
    p->initialColor.a = p->initialColor.a * (_particleAlpha + _particleAlphaRange * randCGFloat(-1, 1));
  }
  
  _timeOfLastUpdate = time;
}

- (void)prepareToDraw
{
  glBindVertexArrayOES(particleAttributesVertexArray);
  glBindBuffer(GL_ARRAY_BUFFER, particleAttributesVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, particleCount * sizeof(R4ParticleAttributes), particleAttributes, GL_STREAM_DRAW);
}

- (void)draw
{
  glDrawArraysInstancedEXT(GL_TRIANGLES, 0, 6, particleCount);
}

@end
