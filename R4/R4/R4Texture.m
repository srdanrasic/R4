//
//  R4Texture.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Texture.h"

@interface R4Texture ()
@property (nonatomic, strong) GLKTextureInfo *glkTextureInfo;
@end

@implementation R4Texture

+ (R4Texture *)textureWithImageNamed:(NSString *)name
{
  R4Texture *tex = [[R4Texture alloc] init];
  
  NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft:[NSNumber numberWithBool:YES],
                            GLKTextureLoaderGenerateMipmaps: [NSNumber numberWithBool:YES]};
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];

  GLKTextureInfo *glkTexture = [GLKTextureLoader textureWithContentsOfFile:[resourcePath stringByAppendingPathComponent:name] options:options error:nil];
  
  if (glkTexture) {
    tex.glkTextureInfo = glkTexture;
    glBindTexture(GL_TEXTURE_2D, glkTexture.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  }
  
  return tex;
}

- (GLuint)textureName
{
  return self.glkTextureInfo.name;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    // TODO
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  // TODO
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  // TODO
  return nil;
}

@end
