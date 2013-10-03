//
//  R4Renderer.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Scene;

@interface R4Renderer : NSObject

@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)render:(R4Scene *)scene;
- (void)resizeFromLayer:(CAEAGLLayer*)layer;

@end
