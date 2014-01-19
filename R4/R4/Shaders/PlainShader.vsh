//
//  PlainShader.h
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

/* Uniforms */
uniform vec4 surface_diffuse_color;
uniform mat4 model_view_projection_matrix;

/* Attributes */
attribute vec4 in_position;
attribute vec2 in_texcoord;

/* Varyings */
varying lowp vec2 out_texcoord;
varying lowp vec4 out_color;

void main()
{
  out_texcoord = in_texcoord;
  out_color = surface_diffuse_color;
  
  gl_Position = model_view_projection_matrix * in_position;
}