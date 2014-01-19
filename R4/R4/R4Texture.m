//
//  R4Texture.m
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Texture.h"

@interface R4TextureInfo : NSObject
@property (nonatomic, assign) GLuint name;
@property (nonatomic, assign) GLenum target;
@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;
@property (nonatomic, assign) BOOL containsMipmaps;
@property (nonatomic, assign) R4TextureFilteringMode filteringMode;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) NSInteger referenceCount;
@end

@interface R4TextureManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *loadedTextures;
+ (R4TextureManager *)shared;
- (R4TextureInfo *)textureNamed:(NSString *)name;
- (void)retainTexture:(NSString *)key;
- (void)releaseTexture:(NSString *)key;
@end

@interface R4Texture ()
@property (nonatomic, weak) R4TextureInfo *textureInfo;
@end


@implementation R4TextureInfo

- (void)dealloc
{
  GLuint name = self.name;
  glDeleteTextures(1, &name);
}

- (void)setFilteringMode:(R4TextureFilteringMode)filteringMode
{
  if (filteringMode == _filteringMode) return;
  
  glBindTexture(GL_TEXTURE_2D, self.name);
  if (filteringMode == R4TextureFilteringLinear) {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  } else {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  }
  
  _filteringMode = filteringMode;
}

@end


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

- (R4TextureInfo *)textureNamed:(NSString *)name
{
  R4TextureInfo *textureInfo = [self.loadedTextures objectForKey:name];
  
  if (!textureInfo) {
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft:[NSNumber numberWithBool:YES], GLKTextureLoaderGenerateMipmaps: [NSNumber numberWithBool:YES]};
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSError *error = nil;
    GLKTextureInfo *glkTexture = [GLKTextureLoader textureWithContentsOfFile:[resourcePath stringByAppendingPathComponent:name] options:options error:&error];
    NSAssert2(error == nil, @"Unable to load texture named [%@]. Error: %@.", name, [error description]);
    
    if (glkTexture) {
      textureInfo = [[R4TextureInfo alloc] init];
      textureInfo.name = glkTexture.name;
      textureInfo.target = glkTexture.target;
      textureInfo.width = glkTexture.width;
      textureInfo.height = glkTexture.height;
      textureInfo.containsMipmaps = glkTexture.containsMipmaps;
      textureInfo.key = name;
      textureInfo.referenceCount = 0;
      [self.loadedTextures setObject:textureInfo forKey:name];
    }
  }
  
  return textureInfo;
}

- (void)retainTexture:(NSString *)key
{
  R4TextureInfo *ti = [self.loadedTextures objectForKey:key];
  if (ti) {
    ti.referenceCount++;
  }
}

- (void)releaseTexture:(NSString *)key
{
  R4TextureInfo *ti = [self.loadedTextures objectForKey:key];
  if (ti) {
    ti.referenceCount--;
    
    if (ti.referenceCount == 0) {
      [self.loadedTextures removeObjectForKey:key];
    }
  }
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
    self.textureInfo = textureInfo;
    [[R4TextureManager shared] retainTexture:textureInfo.key];
  }
  return self;
}

- (void)dealloc
{
  [[R4TextureManager shared] releaseTexture:self.textureInfo.key];
}

- (GLuint)textureName
{
  return self.textureInfo.name;
}

- (void)setFilteringMode:(R4TextureFilteringMode)filteringMode
{
  [self.textureInfo setFilteringMode:filteringMode];
}

- (CGSize)size
{
  return CGSizeMake(self.textureInfo.width, self.textureInfo.height);
}

- (BOOL)usesMipmaps
{
  return self.textureInfo.containsMipmaps;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  R4Texture *texture = [[R4Texture alloc] initWithTextureInfo:self.textureInfo];
  return texture;
}

@end
