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
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 0), std140 ) uniform VRState_block
{
	vec4 leftProjectionTransform;
	vec4 leftUnprojectionTransform;
	vec4 rightProjectionTransform;
	vec4 rightUnprojectionTransform;
	vec2 distortionCoefficients;
	float ipd;
} VRState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 1, 0) ) uniform SLVM_TEXTURE(texture2D, sampler2D) mainTexture;
SLVM_VK_UNIFORM_SAMPLER( ( SLVM_GL_BINDING_VK_SET_BINDING(4, 2, 0) ) ,mainSampler)
layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
vec2 barrelDistort (vec2 arg1);
vec2 distort (vec2 arg1, vec4 arg2, vec4 arg3);
void main ();
vec2 barrelDistort (vec2 arg1)
{
	float _l_r2;
	float _l_r4;
	float _g3;
	_l_r2 = dot(arg1, arg1);
	_l_r4 = (_l_r2 * _l_r2);
	_g3 = ((1.0 + (VRState.distortionCoefficients.x * _l_r2)) + (VRState.distortionCoefficients.x * _l_r4));
	return (arg1 * vec2(_g3, _g3));
}

vec2 distort (vec2 arg1, vec4 arg2, vec4 arg3)
{
	vec2 _l_inputPoint;
	vec2 _l_outputPoint;
	vec2 _g2;
	_l_inputPoint = ((arg1 * arg3.xy) + arg3.zw);
	_g2 = barrelDistort(_l_inputPoint);
	_l_outputPoint = _g2;
	return ((_l_outputPoint * arg2.xy) + arg2.zw);
}

void main ()
{
	bool _l_leftSide;
	vec2 _l_coordinateTranslation;
	vec2 _l_normalizedTexcoord;
	vec4 _l_color;
	vec2 _l_sampleCoordinate;
	vec2 _l_g11;
	vec2 _g1;
	vec2 _g4;
	bool _l_landResult;
	bool _g5;
	bool _g6;
	_l_leftSide = (FragmentInput_sve_texcoord.x < 0.5);
	if (_l_leftSide)
		_l_g11 = vec2(0.0, 0.0);
	else
		_l_g11 = vec2(1.0, 0.0);
	_l_coordinateTranslation = _l_g11;
	_l_normalizedTexcoord = ((FragmentInput_sve_texcoord * vec2(2.0, 1.0)) - _l_coordinateTranslation);
	if (_l_leftSide)
	{
		_g1 = distort(_l_normalizedTexcoord, VRState.leftProjectionTransform, VRState.leftUnprojectionTransform);
		_l_normalizedTexcoord = _g1;
	}
	else
	{
		_g4 = distort(_l_normalizedTexcoord, VRState.rightProjectionTransform, VRState.rightUnprojectionTransform);
		_l_normalizedTexcoord = _g4;
	}
	_l_color = vec4(0.0, 0.0, 0.0, 0.0);
	_l_landResult = false;
	if (0.0 <= _l_normalizedTexcoord.x)
		_l_landResult = (_l_normalizedTexcoord.x <= 1.0);
	_g5 = false;
	if (_l_landResult)
		_g5 = (0.0 <= _l_normalizedTexcoord.y);
	_g6 = false;
	if (_g5)
		_g6 = (_l_normalizedTexcoord.y <= 1.0);
	if (_g6)
	{
		_l_sampleCoordinate = ((_l_normalizedTexcoord + _l_coordinateTranslation) * vec2(0.5, 1.0));
		_l_color = texture(SLVM_COMBINE_SAMPLER_WITH(mainSampler, mainTexture, sampler2D), _l_sampleCoordinate);
	}
	FragmentOutput_sve_color = _l_color;
}

