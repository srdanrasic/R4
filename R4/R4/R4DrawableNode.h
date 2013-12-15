//
//  R4DrawableNode.h
//  R4
//
//  Created by Srđan Rašić on 15/12/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

typedef NS_ENUM(NSInteger, R4BlendMode) {
  R4BlendModeAlpha        = 0,    // Blends the source and destination colors by multiplying the source alpha value.
  R4BlendModeAdd          = 1,    // Blends the source and destination colors by adding them up.
  R4BlendModeSubtract     = 2,    // Blends the source and destination colors by subtracting the source from the destination.
  R4BlendModeMultiply     = 3,    // Blends the source and destination colors by multiplying them.
  R4BlendModeMultiplyX2   = 4,    // Blends the source and destination colors by multiplying them and doubling the result.
  R4BlendModeScreen       = 5,    // FIXME: Description needed
  R4BlendModeReplace      = 6     // Replaces the destination with the source (ignores alpha).
};

@interface R4DrawableNode : R4Node

@property (assign, nonatomic) R4BlendMode blendMode;
@property (strong, nonatomic) R4Color *highlightColor;

@end
