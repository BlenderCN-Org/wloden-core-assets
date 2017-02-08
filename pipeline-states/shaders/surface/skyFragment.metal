#include <metal_stdlib>

struct ObjectStateData
{
	metal::float4x4 matrix;
	metal::float4x4 inverseMatrix;
	metal::float4 color;
	int visible;
};

struct ObjectState_block
{
	ObjectStateData objectState;
};

struct CameraState_block
{
	metal::float4x4 inverseViewMatrix;
	metal::float4x4 viewMatrix;
	metal::float4x4 projectionMatrix;
	float currentTime;
};

struct LightSource
{
	metal::float4 position;
	metal::float4 intensity;
	metal::float3 spotDirection;
	float innerCosCutoff;
	float outerCosCutoff;
	float spotExponent;
	float radius;
};

struct GlobalLightingState_block
{
	metal::float4 groundLighting;
	metal::float4 skyLighting;
	metal::float3 sunDirection;
	int numberOfLights;
	LightSource lightSources[16];
};

struct InstanceObjectState_bufferBlock
{
	ObjectStateData instanceStates[1];
};

struct _SLVM_ShaderStageInput
{
	metal::float3 location0;
	metal::float2 location1;
	metal::float4 location2;
	metal::float3 location3;
	metal::float3 location4;
	metal::float3 location5;
};

struct _SLVM_ShaderStageOutput
{
	metal::float4 location0[[color(0)]];
};

metal::float3 cameraWorldPosition (device const CameraState_block* CameraState);
metal::float3 fresnelSchlick (metal::float3 arg1, float arg2);
float fresnelSchlick (float arg1, float arg2);
fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], metal::texturecube<float> skyTexture [[texture(0)]], metal::sampler skySampler [[sampler(2)]]);
metal::float3 cameraWorldPosition (device const CameraState_block* CameraState)
{
	return CameraState->inverseViewMatrix[3].xyz;
}

metal::float3 fresnelSchlick (metal::float3 arg1, float arg2)
{
	float _l_powFactor;
	float _l_powFactor2;
	float _l_powFactor4;
	float _l_powValue;
	_l_powFactor = (1.0 - arg2);
	_l_powFactor2 = (_l_powFactor * _l_powFactor);
	_l_powFactor4 = (_l_powFactor2 * _l_powFactor2);
	_l_powValue = (_l_powFactor4 * _l_powFactor);
	return (arg1 + ((metal::float3(1.0, 1.0, 1.0) - arg1) * metal::float3(_l_powValue, _l_powValue, _l_powValue)));
}

float fresnelSchlick (float arg1, float arg2)
{
	float _l_powFactor;
	float _l_powFactor2;
	float _l_powFactor4;
	float _l_powValue;
	_l_powFactor = (1.0 - arg2);
	_l_powFactor2 = (_l_powFactor * _l_powFactor);
	_l_powFactor4 = (_l_powFactor2 * _l_powFactor2);
	_l_powValue = (_l_powFactor4 * _l_powFactor);
	return (arg1 + ((1.0 - arg1) * _l_powValue));
}

fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], metal::texturecube<float> skyTexture [[texture(0)]], metal::sampler skySampler [[sampler(2)]])
{
	metal::float4 _l_skyColor;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float4* FragmentOutput_sve_color = &_slvm_stageout.location0;
	thread metal::float3* FragmentInput_sve_position = &_slvm_stagein.location0;
	_l_skyColor = skyTexture.sample(skySampler, (*FragmentInput_sve_position));
	(*FragmentOutput_sve_color) = _l_skyColor;
	return _slvm_stageout;
}

