//
//  R4Drawable.h
//  R4
//
//  Created by Srđan Rašić on 26/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol R4Drawable <NSObject>

@required
- (void)prepareToDraw;
- (void)drawPass;

@end