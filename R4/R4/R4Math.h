//
//  NSObject_R4Math.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

typedef struct {
  GLKVector3 origin;
  GLKVector3 size;
} R4Box;

inline R4Box R4BoxMake(GLKVector3 origin, GLKVector3 size)
{
  R4Box box = {origin, size};
  return box;
}
