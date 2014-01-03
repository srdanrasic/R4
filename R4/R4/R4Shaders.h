
/* File autocompiled from shader files in Shaders/ directory. Changes to this file will be overriden on build! */


static const char * const fshParticleShaderSourceString = "uniform lowp sampler2D texture_sampler; uniform lowp float texture_mask; varying lowp float  out_alpha; varying lowp vec4   out_color; varying lowp vec2   out_texcoord; varying lowp float  out_colorBlendFactor; void main() {   lowp vec4 texel = texture2D(texture_sampler, out_texcoord) + vec4(texture_mask, texture_mask, texture_mask, texture_mask);   lowp vec4 color = mix(texel, out_color, out_colorBlendFactor) * vec4(1.0, 1.0, 1.0, out_alpha);   gl_FragColor = clamp(color, 0.0, 1.0); } ";

static const char * const vshParticleShaderSourceString = "uniform mat4 model_view_projection_matrix; attribute vec4 position; attribute mediump vec2 texcoord; attribute float instanceAlpha; attribute vec4  instanceColor; attribute float instanceColorBlendFactor; attribute mat4  instanceMVM; varying lowp float  out_alpha; varying lowp vec4   out_color; varying lowp vec2   out_texcoord; varying lowp float  out_colorBlendFactor; void main() {   out_alpha = instanceAlpha;   out_color = instanceColor;   out_texcoord = texcoord;   out_colorBlendFactor = instanceColorBlendFactor;      gl_Position = model_view_projection_matrix * instanceMVM * position; } ";

