//
//  R4Texture.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Texture.h"
#import "R4TextureManager.h"

@interface R4Texture () {
  __weak R4TextureInfo *textureInfo_;
}
@end


@implementation R4Texture

+ (R4Texture *)textureWithImageNamed:(NSString *)name
{
  return [[R4Texture alloc] initWithTextureInfo:[[R4TextureManager shared] textureNamed:name]];
}

- (instancetype)initWithTextureInfo:(R4TextureInfo *)textureInfo
{
  self = [super init];
  if (self) {
    textureInfo_ = textureInfo;
    [[R4TextureManager shared] retainTexture:textureInfo->key];
  }
  return self;
}

- (void)dealloc
{
  [[R4TextureManager shared] releaseTexture:textureInfo_->key];
}

- (GLuint)textureName
{
  return textureInfo_->name;
}

- (void)setFilteringMode:(R4TextureFilteringMode)filteringMode
{
  [textureInfo_ setFilteringMode:filteringMode];
}

- (CGSize)size
{
  return CGSizeMake(textureInfo_->width, textureInfo_->height);
}

- (BOOL)usesMipmaps
{
  return textureInfo_->containsMipmaps;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4Texture *texture = [[R4Texture alloc] initWithTextureInfo:textureInfo_];
  return texture;
}

@end
