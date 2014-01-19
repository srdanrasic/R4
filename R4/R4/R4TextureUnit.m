//
//  R4TextureUnit.m
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4TextureUnit.h"

@implementation R4TextureUnit

+ (R4TextureUnit *)textureUnitWithTexture:(R4Texture *)texture
{
  R4TextureUnit *tu = [[R4TextureUnit alloc] init];
  tu.texture = texture;
  return tu;
}

- (void)dealloc
{
  NSLog(@"Deleting texture unit.");
}

@end
