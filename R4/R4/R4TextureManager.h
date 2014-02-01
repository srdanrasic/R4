//
//  R4TextureManager.h
//  R4
//
//  Created by Srđan Rašić on 01/02/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"
#import "R4Texture.h"

@interface R4TextureInfo : NSObject {
  @public
  GLuint name;
  GLenum target;
  GLuint width;
  GLuint height;
  BOOL containsMipmaps;
  NSString *key;
  NSInteger referenceCount;
  
  R4TextureFilteringMode _filteringMode;
}

@property (nonatomic, assign) R4TextureFilteringMode filteringMode;

@end

@interface R4TextureManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *loadedTextures;
+ (R4TextureManager *)shared;
- (R4TextureInfo *)textureNamed:(NSString *)name;
- (void)retainTexture:(NSString *)key;
- (void)releaseTexture:(NSString *)key;
@end
