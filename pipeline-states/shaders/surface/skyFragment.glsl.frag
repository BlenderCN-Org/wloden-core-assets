#version 430
#extension GL_ARB_separate_shader_objects : enable

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

layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 3, 2) ) uniform SLVM_TEXTURE(textureCube, samplerCube) skyTexture;
layout ( location = 0 ) in vec3 FragmentInput_sve_position;
SLVM_VK_UNIFORM_SAMPLER( ( SLVM_GL_BINDING_VK_SET_BINDING(2, 4, 2) ) ,skySampler)
layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
void main ()
{
	vec4 skyColor;
	skyColor = texture(SLVM_COMBINE_SAMPLER_WITH(skySampler, skyTexture, samplerCube), FragmentInput_sve_position);
	FragmentOutput_sve_color = skyColor;
}

