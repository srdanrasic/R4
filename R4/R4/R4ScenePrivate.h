//
//  R4Scene_.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Scene.h"

@interface R4Scene ()

@property (nonatomic, weak, readwrite) R4View *view;
@property (nonatomic, strong, readwrite) R4CameraNode*currentCamera;

- (void)updateParticleEmittersAtTime:(NSTimeInterval)time;

@end
