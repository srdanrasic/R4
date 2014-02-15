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
  return [[self class] textureWithImageNamed:name generateMipmaps:NO];
}

+ (R4Texture *)textureWithImageNamed:(NSString *)name generateMipmaps:(BOOL)generateMipmaps
{
  return [[R4Texture alloc] initWithTextureInfo:[[R4TextureManager shared] textureNamed:name generateMipmaps:generateMipmaps]];
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

- (R4TextureFilteringMode)filteringMode
{
  return [textureInfo_ filteringMode];
}

- (void)setWrapModeS:(R4TextureWrapMode)wrapMode
{
  [textureInfo_ setWrapModeS:wrapMode];
}

- (R4TextureWrapMode)wrapModeS
{
  return [textureInfo_ wrapModeS];
}

- (void)setWrapModeT:(R4TextureWrapMode)wrapMode
{
  [textureInfo_ setWrapModeT:wrapMode];
}

- (R4TextureWrapMode)wrapModeT
{
  return [textureInfo_ wrapModeT];
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
