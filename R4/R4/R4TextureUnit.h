//
//  R4TextureUnit.h
//  R4
//
//  Created by Srđan Rašić on 18/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

#import "R4Base.h"

@class R4Texture;

@interface R4TextureUnit : NSObject {
  R4Texture *_texture;
}

@property (nonatomic, strong) R4Texture *texture;

+ (R4TextureUnit *)textureUnitWithTexture:(R4Texture *)texture;

@end
