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
@property (assign, nonatomic) NSInteger frameInterval;

- (void)presentScene:(R4Scene *)scene;

- (CGPoint)convertPoint:(GLKVector3)point fromScene:(R4Scene *)scene;
- (R4Ray)convertPoint:(CGPoint)point toScene:(R4Scene *)scene;

/* SpriteKit methods that are not implemented */

//@property (assign, nonatomic) BOOL showDrawCount;
//@property (assign, nonatomic) BOOL showNodeCount;
//@property (assign, nonatomic) BOOL ignoresSiblingOrder;
//- (void)presentScene:(R4Scene *)scene transition:(R4Transition *)transition;
//- (R4Texture *)textureFromNode:(R4Node *)node;


@end
