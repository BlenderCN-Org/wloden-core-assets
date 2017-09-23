#include <metal_stdlib>

struct _SLVM_ShaderStageInput
{
	metal::float2 location0[[user(L0)]];
};

struct _SLVM_ShaderStageOutput
{
	metal::float4 location0[[color(0)]];
};

fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], metal::texture2d<float> mainTexture [[texture(0)]], metal::sampler mainSampler [[sampler(0)]]);
fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], metal::texture2d<float> mainTexture [[texture(0)]], metal::sampler mainSampler [[sampler(0)]])
{
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float2* FragmentInput_sve_texcoord = &_slvm_stagein.location0;
	thread metal::float4* FragmentOutput_sve_color = &_slvm_stageout.location0;
	(*FragmentOutput_sve_color) = mainTexture.sample(mainSampler, (*FragmentInput_sve_texcoord));
	return _slvm_stageout;
}

