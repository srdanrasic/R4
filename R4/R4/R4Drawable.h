//
//  R4Drawable.h
//  R4
//
//  Created by Srđan Rašić on 26/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import <Foundation/Foundation.h>

@class R4Material;

@protocol R4Drawable <NSObject>

@required
@property (nonatomic, readonly) R4Material *material;

- (void)prepareToDraw;
- (void)drawPass;

@end