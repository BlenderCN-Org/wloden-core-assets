#include <metal_stdlib>

struct VRState_block
{
	metal::float4 leftProjectionTransform;
	metal::float4 leftUnprojectionTransform;
	metal::float4 rightProjectionTransform;
	metal::float4 rightUnprojectionTransform;
	metal::float2 distortionCoefficients;
	float ipd;
};

struct _SLVM_ShaderStageInput
{
	metal::float2 location0[[user(L0)]];
};

struct _SLVM_ShaderStageOutput
{
	metal::float4 location0[[color(0)]];
};

metal::float2 barrelDistort (metal::float2 arg1, device const VRState_block* VRState);
metal::float2 distort (metal::float2 arg1, metal::float4 arg2, metal::float4 arg3, device const VRState_block* VRState);
fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const VRState_block* VRState [[buffer(0)]], metal::texture2d<float> mainTexture [[texture(0)]], metal::sampler mainSampler [[sampler(0)]]);
metal::float2 barrelDistort (metal::float2 arg1, device const VRState_block* VRState)
{
	float _l_r2;
	float _l_r4;
	float _g1;
	_l_r2 = metal::dot(arg1, arg1);
	_l_r4 = (_l_r2 * _l_r2);
	_g1 = ((1.0 + (VRState->distortionCoefficients.x * _l_r2)) + (VRState->distortionCoefficients.x * _l_r4));
	return (arg1 * metal::float2(_g1, _g1));
}

metal::float2 distort (metal::float2 arg1, metal::float4 arg2, metal::float4 arg3, device const VRState_block* VRState)
{
	metal::float2 _l_inputPoint;
	metal::float2 _l_outputPoint;
	metal::float2 _g2;
	_l_inputPoint = ((arg1 * arg3.xy) + arg3.zw);
	_g2 = barrelDistort(_l_inputPoint, VRState);
	_l_outputPoint = _g2;
	return ((_l_outputPoint * arg2.xy) + arg2.zw);
}

fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const VRState_block* VRState [[buffer(0)]], metal::texture2d<float> mainTexture [[texture(0)]], metal::sampler mainSampler [[sampler(0)]])
{
	bool _l_leftSide;
	metal::float2 _l_coordinateTranslation;
	metal::float2 _l_normalizedTexcoord;
	metal::float4 _l_color;
	metal::float2 _l_sampleCoordinate;
	metal::float2 _l_g11;
	metal::float2 _g3;
	metal::float2 _g4;
	bool _l_landResult;
	bool _g5;
	bool _g6;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float2* FragmentInput_sve_texcoord = &_slvm_stagein.location0;
	thread metal::float4* FragmentOutput_sve_color = &_slvm_stageout.location0;
	_l_leftSide = ((*FragmentInput_sve_texcoord).x < 0.5);
	if (_l_leftSide)
		_l_g11 = metal::float2(0.0, 0.0);
	else
		_l_g11 = metal::float2(1.0, 0.0);
	_l_coordinateTranslation = _l_g11;
	_l_normalizedTexcoord = (((*FragmentInput_sve_texcoord) * metal::float2(2.0, 1.0)) - _l_coordinateTranslation);
	if (_l_leftSide)
	{
		_g3 = distort(_l_normalizedTexcoord, VRState->leftProjectionTransform, VRState->leftUnprojectionTransform, VRState);
		_l_normalizedTexcoord = _g3;
	}
	else
	{
		_g4 = distort(_l_normalizedTexcoord, VRState->rightProjectionTransform, VRState->rightUnprojectionTransform, VRState);
		_l_normalizedTexcoord = _g4;
	}
	_l_color = metal::float4(0.0, 0.0, 0.0, 0.0);
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
		_l_sampleCoordinate = ((_l_normalizedTexcoord + _l_coordinateTranslation) * metal::float2(0.5, 1.0));
		_l_color = mainTexture.sample(mainSampler, _l_sampleCoordinate);
	}
	(*FragmentOutput_sve_color) = _l_color;
	return _slvm_stageout;
}

