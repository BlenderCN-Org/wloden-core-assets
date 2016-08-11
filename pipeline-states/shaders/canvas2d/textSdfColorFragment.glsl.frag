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

layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 2, 0) ) uniform SLVM_TEXTURE(texture2D, sampler2D) fontTexture;
layout ( location = 1 ) in vec2 FragmentInput_sve_texcoord;
SLVM_VK_UNIFORM_SAMPLER( ( SLVM_GL_BINDING_VK_SET_BINDING(2, 3, 1) ) ,fontSampler)
layout ( location = 2 ) in vec4 FragmentInput_sve_color;
layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
void main ()
{
	float _l_fontSample;
	float _l_fontAlpha;
	_l_fontSample = texture(SLVM_COMBINE_SAMPLER_WITH(fontSampler, fontTexture, sampler2D), FragmentInput_sve_texcoord).x;
	_l_fontAlpha = smoothstep(-0.08, 0.04, _l_fontSample);
	FragmentOutput_sve_color = vec4(FragmentInput_sve_color.xyz, (FragmentInput_sve_color.w * _l_fontAlpha));
}

