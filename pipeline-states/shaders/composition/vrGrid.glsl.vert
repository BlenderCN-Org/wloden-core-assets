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
	int _l_cellIndex;
	int _l_cellExtraOffset;
	int _l_column;
	int _l_row;
	int _l_dx;
	int _l_dy;
	float _l_x;
	float _l_y;
	vec2 _l_pos;
	vec2 _l_texcoord;
	float _l_r;
	float _l_r2;
	bool _l_lorResult;
	bool _g1;
	int _l_g26;
	bool _g2;
	bool _g3;
	int _l_g41;
	float _g4;
	_l_cellIndex = (gl_VertexIndex / 6);
	_l_cellExtraOffset = (gl_VertexIndex % 6);
	_l_column = (_l_cellIndex % 16);
	_l_row = (_l_cellIndex / 16);
	_l_lorResult = true;
	if (!((_l_cellExtraOffset == 1)))
		_l_lorResult = (_l_cellExtraOffset == 2);
	_g1 = true;
	if (!(_l_lorResult))
		_g1 = (_l_cellExtraOffset == 5);
	if (_g1)
		_l_g26 = 1;
	else
		_l_g26 = 0;
	_l_dx = _l_g26;
	_g2 = true;
	if (!((_l_cellExtraOffset == 2)))
		_g2 = (_l_cellExtraOffset == 3);
	_g3 = true;
	if (!(_g2))
		_g3 = (_l_cellExtraOffset == 5);
	if (_g3)
		_l_g41 = 1;
	else
		_l_g41 = 0;
	_l_dy = _l_g41;
	_l_x = (float((_l_column + _l_dx)) / 16.0);
	_l_y = (float((_l_row + _l_dy)) / 16.0);
	_l_pos = ((vec2(_l_x, _l_y) * vec2(2.0, 2.0)) - vec2(1.0, 1.0));
	_l_texcoord = ((_l_pos * vec2(0.5, 0.5)) + vec2(0.5, 0.5));
	_l_pos = (_l_pos * vec2(0.5, 1.0));
	_l_r = length(_l_pos);
	_l_r2 = (_l_r * _l_r);
	_g4 = ((1.0 + (0.22 * _l_r2)) + ((0.24 * _l_r2) * _l_r2));
	_l_pos = (_l_pos / vec2(_g4, _g4));
	_l_texcoord = vec2(((_l_texcoord.x * 0.5) + (float(gl_InstanceIndex) * 0.5)), _l_texcoord.y);
	_l_pos = vec2(((_l_pos.x - 0.5) + (float(gl_InstanceIndex) * 1.0)), _l_pos.y);
	VertexOutput_sve_texcoord = _l_texcoord;
	gl_Position = vec4(_l_pos, 0.0, 1.0);
}

