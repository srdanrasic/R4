//
//  ParticleShader.vsh
//
//  Created by Srdan Rasic on 25/12/13.
//  Copyright (c) 2013 Srdan Rasic. All rights reserved.
//

uniform lowp sampler2D texture_sampler;
uniform lowp float texture_mask;

varying lowp vec4   out_color;
varying lowp vec2   out_texcoord;
varying lowp float  out_colorBlendFactor;

void main()
{
  lowp vec4 tex = texture2D(texture_sampler, out_texcoord);
  lowp float alpha = tex.a;
  lowp vec3 color = mix(vec3(tex), vec3(out_color), out_colorBlendFactor);
  gl_FragColor = vec4(color, alpha * out_color.a);
}
