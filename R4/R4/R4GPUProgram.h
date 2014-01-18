//
//  R4GPUProgram.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface R4GPUProgram : NSObject

@property (nonatomic, strong, readonly) NSDictionary *autoUniforms;   // name -> location
@property (nonatomic, strong, readonly) NSArray *attributes;

- (instancetype)initWithVshSource:(const char *)vshSource fshSource:(const char *)fshSource;

@end
