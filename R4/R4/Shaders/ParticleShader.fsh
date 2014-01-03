//
//  ParticleShader.vsh
//
//  Created by Srdan Rasic on 25/12/13.
//  Copyright (c) 2013 Srdan Rasic. All rights reserved.
//

uniform lowp sampler2D texture_sampler;
uniform lowp float texture_mask;

varying lowp float  out_alpha;
varying lowp vec4   out_color;
varying lowp vec2   out_texcoord;
varying lowp float  out_colorBlendFactor;

void main()
{
  lowp vec4 texel = texture2D(texture_sampler, out_texcoord) + vec4(texture_mask, texture_mask, texture_mask, texture_mask);
  lowp vec4 color = mix(texel, out_color, out_colorBlendFactor) * vec4(1.0, 1.0, 1.0, out_alpha);
  gl_FragColor = clamp(color, 0.0, 1.0);
}
