//
//  Blinn Phong Shader - per vertex lighting
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//

struct LightParameters {
  vec4  position;
  vec4  ambient_color;
  vec4  diffuse_color;
  vec4  specular_color;
};

const int max_number_of_lights = 3;

/* Uniforms */
uniform int number_of_lights;
uniform LightParameters lights[max_number_of_lights];

uniform vec4  surface_ambient_color;
uniform vec4  surface_diffuse_color;
uniform vec4  surface_specular_color;
uniform float surface_shininess;

uniform mat4 model_view_matrix;
uniform mat4 model_view_projection_matrix;
uniform mat3 normal_matrix;

/* Attributes */
attribute mediump vec3 in_position;
attribute mediump vec3 in_normal;
attribute mediump vec2 in_texcoord;

/* Varyings */
varying lowp vec2 texcoord;
varying lowp vec4 frag_color_primary;
varying lowp vec4 frag_color_secondary;

void main()
{
  /* Calculate texture coordinate(s) */
  texcoord = in_texcoord;
  
  /* Vertex position */
  gl_Position = model_view_projection_matrix * vec4(in_position, 1.0);

  /* Light */
  mediump vec3 vertex_normal = normal_matrix * normalize(in_normal);
  mediump vec4 vertex_position_eyespace = model_view_matrix * vec4(in_position, 1.0);
  
  vec4 ambient = vec4(0.0, 0.0, 0.0, 1.0);
  vec4 diffuse = vec4(0.0, 0.0, 0.0, 1.0);
  vec4 specular = vec4(0.0, 0.0, 0.0, 1.0);
  
  for (int i = 0; i < number_of_lights; i++) {
    /* Ambient */
    ambient += surface_ambient_color * lights[i].ambient_color;
    
    /* Diffuse */
    mediump vec3 s = normalize(vec3(lights[i].position - vertex_position_eyespace));
    mediump float sDotN = max( dot(s, vertex_normal), 0.0 );
    diffuse += lights[i].diffuse_color * surface_diffuse_color * sDotN;
    
    /* Specular */
    if( sDotN > 0.0 ) {
      vec3 v = normalize(-vertex_position_eyespace.xyz);
      vec3 r = reflect(-s, vertex_normal);
      specular += lights[i].specular_color * surface_specular_color * pow(max(dot(r, v), 0.0), surface_shininess);
    }
  }

  frag_color_primary = ambient + diffuse;
  frag_color_secondary = specular;
}
