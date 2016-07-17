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

layout ( location = 0 ) in vec3 FragmentInput_sve_position;
layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
layout ( location = 2 ) in vec4 FragmentInput_sve_color;
vec3 stippleFunction (vec3 arg1)
{
	return ((fsign(cos((arg1 * vec3(62.83185307179586, 62.83185307179586, 62.83185307179586)))) * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5));
}

void main ()
{
	float stippleFactor;
	vec3 stipples;
	float alpha;
	vec3 _g1;
	stippleFactor = 10.0;
	_g1 = stippleFunction((FragmentInput_sve_position * vec3(stippleFactor, stippleFactor, stippleFactor)));
	stipples = _g1;
	alpha = ((stipples.x * stipples.y) * stipples.z);
	FragmentOutput_sve_color = vec4(stipples, 1.0);
	FragmentOutput_sve_color = vec4(FragmentInput_sve_color.xyz, (FragmentInput_sve_color.w * alpha));
}

