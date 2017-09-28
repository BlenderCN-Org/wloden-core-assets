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

layout ( location = 0 ) in vec2 FragmentInput_sve_texcoord;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 1, 0) ) uniform SLVM_TEXTURE(texture2D, sampler2D) mainTexture;
SLVM_VK_UNIFORM_SAMPLER( ( SLVM_GL_BINDING_VK_SET_BINDING(2, 2, 0) ) ,mainSampler)
layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
void main ();
void main ()
{
	vec4 _l_left;
	vec4 _l_right;
	_l_left = texture(SLVM_COMBINE_SAMPLER_WITH(mainSampler, mainTexture, sampler2D), (FragmentInput_sve_texcoord * vec2(0.5, 1.0)));
	_l_right = texture(SLVM_COMBINE_SAMPLER_WITH(mainSampler, mainTexture, sampler2D), ((FragmentInput_sve_texcoord * vec2(0.5, 1.0)) + vec2(0.5, 0.0)));
	FragmentOutput_sve_color = vec4(_l_left.x, _l_right.yz, 1.0);
}

