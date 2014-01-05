
/* File autocompiled from shader files in Shaders/ directory. Changes to this file will be overriden on build! */


static const char * const fshParticleShaderSourceString = "uniform lowp sampler2D texture_sampler; uniform lowp float texture_mask; varying lowp vec4   out_color; varying lowp vec2   out_texcoord; varying lowp float  out_colorBlendFactor; void main() {   lowp vec4 tex = texture2D(texture_sampler, out_texcoord);   lowp float alpha = tex.a;   lowp vec3 color = mix(vec3(tex), vec3(out_color), out_colorBlendFactor);   gl_FragColor = vec4(color, alpha * out_color.a); } ";

static const char * const vshParticleShaderSourceString = "uniform mat4 model_view_projection_matrix; attribute vec4 position; attribute mediump vec2 texcoord; attribute vec4  instanceColor; attribute float instanceColorBlendFactor; attribute mat4  instanceMVM; varying lowp vec4   out_color; varying lowp vec2   out_texcoord; varying lowp float  out_colorBlendFactor; void main() {   out_color = instanceColor;   out_texcoord = texcoord;   out_colorBlendFactor = instanceColorBlendFactor;   gl_Position = model_view_projection_matrix * instanceMVM * position; } ";

