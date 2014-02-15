//
//  R4PairKey.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R4PairKey : NSObject  <NSCopying> {
  __weak id o1_;
  __weak id o2_;
}

+ (R4PairKey *)keyWithO1:(id)o1 o2:(id)o2;

@end
