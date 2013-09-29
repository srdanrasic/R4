//
//  R4View.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Scene, R4Node, R4Transition, R4Texture;

@interface R4View : UIView

@property (strong, nonatomic, readonly) R4Scene *scene;
@property (assign, nonatomic, getter = isPaused) BOOL paused;
@property (assign, nonatomic) BOOL showFPS;
@property (assign, nonatomic) BOOL showDrawCount;
@property (assign, nonatomic) BOOL showNodeCount;
@property (assign, nonatomic) NSInteger frameInterval;
@property (assign, nonatomic) BOOL ignoresSiblingOrder;

- (void)presentScene:(R4Scene *)scene;
- (void)presentScene:(R4Scene *)scene transition:(R4Transition *)transition;

- (R4Texture *)textureFromNode:(R4Node *)node;

- (CGPoint)convertPoint:(CGPoint)point fromScene:(R4Scene *)scene;
- (CGPoint)convertPoint:(CGPoint)point toScene:(R4Scene *)scene;

@end
