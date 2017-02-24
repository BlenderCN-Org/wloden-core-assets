#include <metal_stdlib>

struct CanvasViewport_block
{
	metal::float4x4 projectionMatrix;
	metal::float4x4 viewMatrix;
};

struct CurrentColorRamp_block
{
	int colorRampIndex;
	int colorRampSize;
};

struct ColorRampEntry
{
	float edge;
	metal::float4 color;
};

struct ColorRamps_bufferBlock
{
	ColorRampEntry entries[1];
};

struct _SLVM_ShaderStageInput
{
	metal::float4 location0[[user(L0)]];
	metal::float2 location1[[user(L1)]];
	metal::float4 location2[[user(L2)]];
};

struct _SLVM_ShaderStageOutput
{
	metal::float4 location0[[color(0)]];
};

metal::float4 evaluateColorRamp (float arg1, constant const CurrentColorRamp_block* CurrentColorRamp, device const ColorRamps_bufferBlock* ColorRamps);
fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], metal::texture2d<float> fontTexture [[texture(1)]], metal::sampler fontSampler [[sampler(1)]]);
metal::float4 evaluateColorRamp (float arg1, constant const CurrentColorRamp_block* CurrentColorRamp, device const ColorRamps_bufferBlock* ColorRamps)
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
	if (CurrentColorRamp->colorRampSize == 0)
		return metal::float4(1.0, 1.0, 1.0, 1.0);
	_l_a = 0;
	_l_b = CurrentColorRamp->colorRampSize;
	_l_lastResult = _l_a;
	for (;(_l_a < _l_b); )
	{
		_l_m = ((_l_a + _l_b) / 2);
		if (ColorRamps->entries[(CurrentColorRamp->colorRampIndex + _l_m)].edge <= arg1)
		{
			_l_lastResult = _l_m;
			_l_a = (_l_m + 1);
		}
		else
			_l_b = _l_m;
	}
	_l_entryIndex = (CurrentColorRamp->colorRampIndex + _l_lastResult);
	_l_prevEdge = ColorRamps->entries[_l_entryIndex].edge;
	_l_landResult = false;
	if (_l_lastResult == 0)
		_l_landResult = (arg1 <= _l_prevEdge);
	_l_lorResult = true;
	if (!(_l_landResult))
		_l_lorResult = (_l_lastResult == (CurrentColorRamp->colorRampSize - 1));
	if (_l_lorResult)
		return ColorRamps->entries[_l_entryIndex].color;
	_l_nextEdge = ColorRamps->entries[(_l_entryIndex + 1)].edge;
	_l_mixFactor = ((arg1 - _l_prevEdge) / (_l_nextEdge - _l_prevEdge));
	return metal::mix(ColorRamps->entries[_l_entryIndex].color, ColorRamps->entries[(_l_entryIndex + 1)].color, metal::float4(_l_mixFactor, _l_mixFactor, _l_mixFactor, _l_mixFactor));
}

fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], metal::texture2d<float> fontTexture [[texture(1)]], metal::sampler fontSampler [[sampler(1)]])
{
	float _l_fontSample;
	float _l_fontAlpha;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float4* FragmentOutput_sve_color = &_slvm_stageout.location0;
	thread metal::float4* FragmentInput_sve_color = &_slvm_stagein.location2;
	thread metal::float2* FragmentInput_sve_texcoord = &_slvm_stagein.location1;
	_l_fontSample = fontTexture.sample(fontSampler, (*FragmentInput_sve_texcoord)).x;
	_l_fontAlpha = metal::smoothstep(-0.08, 0.04, _l_fontSample);
	(*FragmentOutput_sve_color) = metal::float4((*FragmentInput_sve_color).xyz, ((*FragmentInput_sve_color).w * _l_fontAlpha));
	return _slvm_stageout;
}

