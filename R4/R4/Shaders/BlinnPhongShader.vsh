//
//  BlinnPhongShader.h
//  R4
//
//  Created by Srđan Rašić on 19/01/14.
//  Copyright (c) 2014 Srđan Rašić. All rights reserved.
//
precision mediump float;

/* Uniforms */
uniform vec4  light_ambient_color;
uniform vec4  light_diffuse_color;
uniform vec4  light_specular_color;
uniform vec4  light_position;
uniform vec3  light_half_vector;
uniform vec3  light_attenuation;
uniform vec3  spotlight_direction;
uniform float spotlight_exponent;
uniform float spotlight_cutoff;
uniform float spotlight_cos_cutoff;

uniform vec4  surface_ambient_color;
uniform vec4  surface_diffuse_color;
uniform vec4  surface_specular_color;
uniform float surface_shininess;

uniform mat4 model_view_matrix;
uniform mat4 model_view_projection_matrix;
uniform mediump mat3 normal_matrix;

uniform int num_of_enabled_lights;
uniform int need_local_viewer;     // set true if there is Point or Spot light in scene
uniform vec4 scene_ambient_color;


/* Attributes */
attribute vec4 in_position;
attribute mediump vec3 in_normal;
attribute mediump vec4 in_texcoord;

/* Varyings */
varying lowp vec4 texcoord;
varying lowp vec4 frag_color_primary;
varying lowp vec4 frag_color_secondary;

/* Other */
//invariant gl_Position;

/* Functions */
void DirectionalLight(const in  vec3    normal,
                      inout vec4    ambient,
                      inout vec4    diffuse,
                      inout vec4    specular)
{
  float nDotVP; // normal . light direction
  float nDotHV; // normal . half vector
  float pf;   // power factor;
  
  nDotVP = max(0.0, dot(normal, normalize(vec3(light_position))));
  nDotHV = max(0.0, dot(normal, vec3(light_half_vector)));
  
  if (nDotVP == 0.0)
    pf = 0.0;
  else
    pf = pow(nDotHV, surface_shininess);
  
  ambient += light_ambient_color;
  diffuse += light_diffuse_color * nDotVP;
  specular += light_specular_color * pf;
}

void PointLight(const in vec3   eye,
                const in vec3   eye_vertex_position3,
                const in mediump vec3  normal,
                inout vec4  ambient,
                inout vec4  diffuse,
                inout vec4  specular)
{
  float nDotVP; // normal . light direction
  float nDotHV; // normal . half vector
  float pf;   // power factor;
  float attenuation; // computed attenuation factor
  float d; // distance from vertex to light source
  vec3 VP; // direction from vertex to light source
  vec3 half_vector; // direction of max highlights
  
  VP = vec3(light_position) - eye_vertex_position3;
  d = length(VP);
  VP = normalize(VP);
  
  attenuation = 1.0 / (light_attenuation.x +
                       light_attenuation.y * d +
                       light_attenuation.z * d * d);
  
  half_vector = normalize(VP + eye);
  
  nDotVP = max(0.0, dot(normal, VP));
  nDotHV = max(0.0, dot(normal, half_vector));
  
  if (nDotVP == 0.0)
    pf = 0.0;
  else
    pf = pow(nDotHV, surface_shininess);
  
  ambient += light_ambient_color * attenuation;
  diffuse += light_diffuse_color * nDotVP * attenuation;
  specular += light_specular_color * pf * attenuation;
}

void SpotLight(const in vec3    eye,
               const in vec3    eye_vertex_position3,
               const in  vec3   normal,
               inout vec4   ambient,
               inout vec4   diffuse,
               inout vec4   specular)
{
  float nDotVP; // normal . light direction
  float nDotHV; // normal . half vector
  float pf;   // power factor;
  float attenuation; // computed attenuation factor
  float spot_dot; // cosine of angle between spotlight
  float spot_attenuation; // spotlight attenutation factor
  float d; // distance from vertex to light source
  vec3 VP; // direction from vertex to light source
  vec3 half_vector; // direction of max highlights
  
  VP = vec3(light_position) - eye_vertex_position3;
  d = length(VP);
  VP = normalize(VP);
  
  attenuation = 1.0 / (light_attenuation.x +
                       light_attenuation.y * d +
                       light_attenuation.z * d * d);
  
  spot_dot = dot(-VP, normalize(spotlight_direction));
  if (spot_dot < spotlight_cos_cutoff)
    spot_attenuation = 0.0;
  else
    spot_attenuation = pow(spot_dot, spotlight_exponent);
  
  attenuation *= spot_attenuation;
  
  half_vector = normalize(VP + eye);
  
  nDotVP = max(0.0, dot(normal, VP));
  nDotHV = max(0.0, dot(normal, half_vector));
  
  if (nDotVP == 0.0)
    pf = 0.0;
  else
    pf = pow(nDotHV, surface_shininess);
  
  ambient += light_ambient_color * attenuation;
  diffuse += light_diffuse_color * nDotVP * attenuation;
  specular += light_specular_color * pf * attenuation;
}



void main()
{
  vec4 eye_vertex_position4;
  vec3 eye_vertex_position3;
  
  vec3 normal;
  vec3 eye;
  
  /* Calculate normal */
  normal = normalize(normal_matrix * in_normal);  // optimize if possible
  
  /* Calculate texture coordinate(s) */
  texcoord = in_texcoord;
  
  /* Calculate positions */
  //if (need_local_viewer == 1) {
    eye_vertex_position4 = model_view_matrix * in_position;
    eye_vertex_position3 = (vec3(eye_vertex_position4)) / eye_vertex_position4.w;
    eye = -normalize(eye_vertex_position3);
  //}
  
  lowp vec4 ambient = vec4(0.0);
  lowp vec4 diffuse = vec4(0.0);
  lowp vec4 specular = vec4(0.0);
  
  //if (light_position.w == 0.0)
    //DirectionalLight(normal, ambient, diffuse, specular);
  //else if (spotlight_cutoff == 180.0)
    PointLight(eye, eye_vertex_position3, normal, ambient, diffuse, specular);
  //else
    //SpotLight(eye, eye_vertex_position3, normal, ambient, diffuse, specular);
  
  frag_color_primary = clamp(scene_ambient_color + ambient * surface_ambient_color + diffuse * surface_diffuse_color, 0.0, 1.0);
  frag_color_secondary = clamp(vec4(specular.rgb * surface_specular_color.rgb, 1.0), 0.0, 1.0);
  
  gl_Position = model_view_projection_matrix * in_position;
}
