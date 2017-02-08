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

struct ColorRampEntry
{
	float edge;
	vec4 color;
};

layout ( location = 0 ) in vec4 FragmentInput_sve_position;
layout ( location = 1 ) in vec2 FragmentInput_sve_texcoord;
layout ( location = 2 ) in vec4 FragmentInput_sve_color;
layout (push_constant) uniform CurrentColorRamp_block CurrentColorRamp;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 1), std430 ) buffer ColorRamps_bufferBlock
{
	ColorRampEntry entries[];
} ColorRamps;

layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
vec4 evaluateColorRamp (float arg1);
void main ();
vec4 evaluateColorRamp (float arg1)
{
	int _l_a;
	int _l_b;
	int _l_lastResult;
	int _l_m;
	int _l_entryIndex;
	float _l_prevEdge;
	float _l_nextEdge;
	float _l_mixFactor;
	bool _l_landResult;
	bool _l_lorResult;
	if (CurrentColorRamp.colorRampSize == 0)
		return vec4(1.0, 1.0, 1.0, 1.0);
	_l_a = 0;
	_l_b = CurrentColorRamp.colorRampSize;
	_l_lastResult = _l_a;
	while ((_l_a < _l_b))
	{
		_l_m = ((_l_a + _l_b) / 2);
		if (ColorRamps.entries[(CurrentColorRamp.colorRampIndex + _l_m)].edge <= arg1)
		{
			_l_lastResult = _l_m;
			_l_a = (_l_m + 1);
		}
		else
			_l_b = _l_m;
	}
	_l_entryIndex = (CurrentColorRamp.colorRampIndex + _l_lastResult);
	_l_prevEdge = ColorRamps.entries[_l_entryIndex].edge;
	_l_landResult = false;
	if (_l_lastResult == 0)
		_l_landResult = (arg1 <= _l_prevEdge);
	_l_lorResult = true;
	if (!(_l_landResult))
		_l_lorResult = (_l_lastResult == (CurrentColorRamp.colorRampSize - 1));
	if (_l_lorResult)
		return ColorRamps.entries[_l_entryIndex].color;
	_l_nextEdge = ColorRamps.entries[(_l_entryIndex + 1)].edge;
	_l_mixFactor = ((arg1 - _l_prevEdge) / (_l_nextEdge - _l_prevEdge));
	return mix(ColorRamps.entries[_l_entryIndex].color, ColorRamps.entries[(_l_entryIndex + 1)].color, vec4(_l_mixFactor, _l_mixFactor, _l_mixFactor, _l_mixFactor));
}

void main ()
{
	float _l_coord;
	vec2 _l_point;
	vec2 _l_start;
	vec2 _l_end;
	vec2 _l_delta;
	vec2 _l_center;
	vec2 _l_focalPoint;
	float _l_radius;
	vec2 _g1;
	vec2 _l_focalDelta;
	float _l_E;
	float _l_r2;
	vec4 _g2;
	_l_point = FragmentInput_sve_position.xy;
	if (FragmentInput_sve_texcoord.x == 0.0)
	{
		_l_start = FragmentInput_sve_color.xy;
		_l_end = FragmentInput_sve_color.zw;
		_l_delta = (_l_end - _l_start);
		_l_coord = (dot(_l_delta, (_l_point - _l_start)) / dot(_l_delta, _l_delta));
	}
	else
	{
		_l_center = FragmentInput_sve_color.xy;
		_l_focalPoint = FragmentInput_sve_color.zw;
		_l_radius = FragmentInput_sve_texcoord.y;
		_g1 = (_l_point - _l_focalPoint);
		_l_focalDelta = (_l_center - _l_focalPoint);
		_l_E = ((_g1.x * _l_focalDelta.y) - (_g1.y * _l_focalDelta.x));
		_l_r2 = (_l_radius * _l_radius);
		_l_coord = ((dot(_g1, _l_focalDelta) + sqrt(((_l_r2 * dot(_g1, _g1)) - (_l_E * _l_E)))) / (_l_r2 - dot(_l_focalDelta, _l_focalDelta)));
	}
	_g2 = evaluateColorRamp(_l_coord);
	FragmentOutput_sve_color = _g2;
}

