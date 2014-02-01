//
//  R4DefaultSceneManager.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"
#import "R4SceneManager.h"

@interface R4DefaultSceneManager : NSObject <R4SceneManager>

- (instancetype)initWithScene:(R4Scene *)scene;

@end
