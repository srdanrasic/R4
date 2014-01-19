//
//  PlainShader.m
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

uniform lowp sampler2D texture_sampler;
uniform lowp float texture_mask;

varying lowp vec2 out_texcoord;
varying lowp vec4 out_color;

void main()
{
  lowp vec4 texel = texture2D(texture_sampler, out_texcoord) + vec4(texture_mask, texture_mask, texture_mask, texture_mask);
  gl_FragColor = texel * out_color;
}
