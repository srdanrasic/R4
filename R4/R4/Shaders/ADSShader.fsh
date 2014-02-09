//
//  Blinn Phong Shader
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

uniform lowp sampler2D texture_sampler;
uniform lowp float texture_mask;

varying lowp vec2 texcoord;
varying lowp vec4 frag_color_primary;
varying lowp vec4 frag_color_secondary;

void main()
{
  /* Get pixel */
  lowp vec4 texel = texture2D(texture_sampler, texcoord.st) + vec4(texture_mask, texture_mask, texture_mask, texture_mask);
  
  /* Final color */
  gl_FragColor = clamp(texel * frag_color_primary + frag_color_secondary, 0.0, 1.0);
}
