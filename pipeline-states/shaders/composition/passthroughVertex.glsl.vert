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

layout ( location = 0 ) out vec2 VertexOutput_sve_texcoord;
void main ();
void main ()
{
	vec2 _l_position;
	_l_position = vec2(0.0, 0.0);
	if (gl_VertexIndex == 0)
		_l_position = vec2(-1.0, 1.0);
	else
	{
		if (gl_VertexIndex == 1)
			_l_position = vec2(1.0, 1.0);
		else
		{
			if (gl_VertexIndex == 2)
				_l_position = vec2(-1.0, -1.0);
			else
			{
				if (gl_VertexIndex == 3)
					_l_position = vec2(1.0, -1.0);
			}
		}
	}
	VertexOutput_sve_texcoord = ((_l_position * vec2(0.5, 0.5)) + vec2(0.5, 0.5));
	gl_Position = vec4(_l_position, 0.0, 1.0);
}

