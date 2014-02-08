//
//  R4TextureManager.m
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4TextureManager.h"

#pragma mark -
#pragma mark Texture Info

@implementation R4TextureInfo

- (void)dealloc
{
  glDeleteTextures(1, &name);
}

- (void)setFilteringMode:(R4TextureFilteringMode)filteringMode
{
  if (filteringMode == _filteringMode) return;
  
  glBindTexture(GL_TEXTURE_2D, name);
  if (filteringMode == R4TextureFilteringLinear) {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  } else {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  }
  
  _filteringMode = filteringMode;
}

- (void)setWrapModeS:(R4TextureWrapMode)wrapMode
{
  if (_wrapModeS == wrapMode) return;
  
  glBindTexture(GL_TEXTURE_2D, name);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapMode);
}

- (void)setWrapModeT:(R4TextureWrapMode)wrapMode
{
  if (_wrapModeT == wrapMode) return;
  
  glBindTexture(GL_TEXTURE_2D, name);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapMode);
}

@end

#pragma mark -
#pragma mark Texture Manager

@implementation R4TextureManager

static R4TextureManager *_R4TextureManagerInstance = nil;

+ (R4TextureManager *)shared
{
  if (_R4TextureManagerInstance == nil) {
    _R4TextureManagerInstance = [[[self class] alloc] init];
  }
  return _R4TextureManagerInstance;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.loadedTextures = [NSMutableDictionary dictionary];
  }
  return self;
}

- (R4TextureInfo *)textureNamed:(NSString *)name generateMipmaps:(BOOL)generateMipmaps
{
  R4TextureInfo *textureInfo = [self.loadedTextures objectForKey:name];
  
  if (!textureInfo) {
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft:[NSNumber numberWithBool:YES], GLKTextureLoaderGenerateMipmaps: [NSNumber numberWithBool:generateMipmaps]};
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSError *error = nil;
    GLKTextureInfo *glkTexture = [GLKTextureLoader textureWithContentsOfFile:[resourcePath stringByAppendingPathComponent:name] options:options error:&error];
    NSAssert2(error == nil, @"Unable to load texture named [%@]. Error: %@.", name, [error description]);
    
    if (glkTexture) {
      textureInfo = [[R4TextureInfo alloc] init];
      textureInfo->name = glkTexture.name;
      textureInfo->target = glkTexture.target;
      textureInfo->width = glkTexture.width;
      textureInfo->height = glkTexture.height;
      textureInfo->containsMipmaps = glkTexture.containsMipmaps;
      textureInfo->key = name;
      textureInfo->referenceCount = 0;
      [self.loadedTextures setObject:textureInfo forKey:name];
    }
  }
  
  return textureInfo;
}

- (void)retainTexture:(NSString *)key
{
  R4TextureInfo *ti = [self.loadedTextures objectForKey:key];
  if (ti) {
    ti->referenceCount++;
  }
}

- (void)releaseTexture:(NSString *)key
{
  R4TextureInfo *ti = [self.loadedTextures objectForKey:key];
  if (ti) {
    ti->referenceCount--;
    
    if (ti->referenceCount == 0) {
      [self.loadedTextures removeObjectForKey:key];
    }
  }
}

@end