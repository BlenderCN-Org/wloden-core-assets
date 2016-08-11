#version 430
#extension GL_ARB_separate_shader_objects : enable
#pragma SLVM

#ifdef VULKAN
#define SLVM_GL_BINDING_VK_SET_BINDING(glb, s, b) set = s, binding = b
#define SLVM_VK_UNIFORM_SAMPLER(lc, name) layout lc uniform sampler name;
#define SLVM_COMBINE_SAMPLER_WITH(sampler, texture, samplerType) samplerType(texture, sampler)
#define SLVM_TEXTURE(vulkanType, openglType) vulkanType
#else
#define SLVM_GL_BINDING_VK_SET_BINDING(glb, s, b) binding = glb
#define SLVM_VK_UNIFORM_SAMPLER(lc, name) /* Declaration removed */
#define SLVM_COMBINE_SAMPLER_WITH(sampler, texture, samplerType) texture
#define SLVM_TEXTURE(vulkanType, openglType) openglType
#endif

layout ( location = 2 ) in vec4 VertexInput_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 1 ) in vec2 VertexInput_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 0), std140 ) uniform CanvasViewport_block
{
	mat4 projectionMatrix;
	mat4 viewMatrix;
} CanvasViewport;

layout ( location = 0 ) in vec2 VertexInput_sve_position;
layout ( location = 0 ) out vec4 VertexOutput_sve_position;
void main ()
{
	VertexOutput_sve_color = VertexInput_sve_color;
	VertexOutput_sve_texcoord = VertexInput_sve_texcoord;
	VertexOutput_sve_position = (CanvasViewport.viewMatrix * vec4(VertexInput_sve_position, 0.0, 1.0));
	gl_Position = (CanvasViewport.projectionMatrix * VertexOutput_sve_position);
}

