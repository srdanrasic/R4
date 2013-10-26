//
//  R4Texture.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class CIFilter;

typedef NS_ENUM(NSInteger, R4TextureFilteringMode) {
  R4TextureFilteringNearest,
  R4TextureFilteringLinear,
};

@interface R4Texture : NSObject <NSCopying, NSCoding>

//+ (R4Texture *)textureWithImageNamed:(NSString *)name;
//+ (R4Texture *)textureWithRect:(CGRect)rect inTexture:(R4Texture *)texture;
//+ (R4Texture *)textureWithCGImage:(CGImageRef)image;
//+ (R4Texture *)textureWithImage:(UIImage *)image;
//+ (R4Texture *)textureWithData:(NSData *)pixelData size:(CGSize)size;
//+ (R4Texture *)textureWithData:(NSData *)pixelData size:(CGSize)size rowLength:(unsigned int)rowLength alignment:(unsigned int)alignment;
//- (R4Texture *)textureByApplyingCIFilter:(CIFilter *)filter;
//- (CGRect)textureRect; // {(0,0) (1,1)}
//- (CGSize)size; // points

//@property (nonatomic) R4TextureFilteringMode filteringMode;
//@property (nonatomic) BOOL usesMipmaps; // 2^n

//+ (void)preloadTextures:(NSArray *)textures withCompletionHandler:(void(^)(void))completionHandler;
//- (void)preloadWithCompletionHandler:(void(^)(void))completionHandler;

@end
