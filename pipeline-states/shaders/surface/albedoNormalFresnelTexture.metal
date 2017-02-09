#include <metal_stdlib>

struct MaterialState_block
{
	metal::float4 albedo;
	metal::float3 fresnel;
	float smoothness;
};

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
	metal::float3 location0[[user(L0)]];
	metal::float2 location1[[user(L1)]];
	metal::float4 location2[[user(L2)]];
	metal::float3 location3[[user(L3)]];
	metal::float3 location4[[user(L4)]];
	metal::float3 location5[[user(L5)]];
};

struct _SLVM_ShaderStageOutput
{
	metal::float4 location0[[color(0)]];
};

metal::float3 cameraWorldPosition (device const CameraState_block* CameraState);
metal::float3 fresnelSchlick (metal::float3 arg1, float arg2);
float fresnelSchlick (float arg1, float arg2);
void forwardLightingModel (thread metal::float4* color, metal::float3 normal, metal::float3 viewVector, metal::float3 position, metal::float4 albedo, float smoothness, metal::float3 fresnel, device const GlobalLightingState_block* GlobalLightingState);
fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const GlobalLightingState_block* GlobalLightingState [[buffer(4)]], metal::texture2d<float> normalTexture [[texture(1)]], metal::sampler normalSampler [[sampler(1)]], device const MaterialState_block* MaterialState [[buffer(5)]], metal::texture2d<float> albedoTexture [[texture(0)]], metal::sampler albedoSampler [[sampler(0)]], metal::texture2d<float> fresnelTexture [[texture(2)]]);
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

void forwardLightingModel (thread metal::float4* color, metal::float3 normal, metal::float3 viewVector, metal::float3 position, metal::float4 albedo, float smoothness, metal::float3 fresnel, device const GlobalLightingState_block* GlobalLightingState)
{
	metal::float3 _l_albedoColor;
	float _l_specularPower;
	float _l_specularNormalization;
	metal::float3 _l_accumulatedColor;
	float _l_hemiFactor;
	int _l_i;
	LightSource _l_lightSource;
	metal::float3 _l_L;
	float _l_dist;
	float _l_NdotL;
	float _l_spotCos;
	float _l_spotAttenuation;
	float _l_attenuationDistance;
	float _l_attDen;
	float _l_attenuation;
	metal::float3 _l_H;
	metal::float3 _l_F;
	float _l_NdotH;
	float _l_D;
	float _g1;
	metal::float3 _g2;
	_l_albedoColor = albedo.xyz;
	_l_specularPower = metal::exp2((10.0 * smoothness));
	_l_specularNormalization = ((_l_specularPower + 2.0) * 0.125);
	_l_accumulatedColor = metal::float3(0.0, 0.0, 0.0);
	_l_hemiFactor = ((metal::dot(normal, GlobalLightingState->sunDirection) * 0.5) + 0.5);
	_l_accumulatedColor = (_l_accumulatedColor + (_l_albedoColor * metal::mix(GlobalLightingState->groundLighting.xyz, GlobalLightingState->skyLighting.xyz, metal::float3(_l_hemiFactor, _l_hemiFactor, _l_hemiFactor))));
	_l_i = 0;
	for (;(_l_i < GlobalLightingState->numberOfLights); _l_i = (_l_i + 1))
	{
		_l_lightSource = GlobalLightingState->lightSources[_l_i];
		_g1 = _l_lightSource.position.w;
		_l_L = (GlobalLightingState->lightSources[_l_i].position.xyz - (position * metal::float3(_g1, _g1, _g1)));
		_l_dist = metal::length(_l_L);
		_l_L = (_l_L / metal::float3(_l_dist, _l_dist, _l_dist));
		_l_NdotL = metal::max(metal::dot(normal, _l_L), 0.0);
		if (_l_NdotL == 0.0)
			continue;
		_l_spotCos = 1.0;
		if (_l_lightSource.outerCosCutoff > -1.0)
			_l_spotCos = metal::dot(_l_L, _l_lightSource.spotDirection);
		if (_l_spotCos < _l_lightSource.outerCosCutoff)
			continue;
		_l_spotAttenuation = (metal::smoothstep(_l_lightSource.outerCosCutoff, _l_lightSource.innerCosCutoff, _l_spotCos) * metal::pow(_l_spotCos, _l_lightSource.spotExponent));
		_l_attenuationDistance = metal::max(0.0, (_l_dist - _l_lightSource.radius));
		_l_attDen = (1.0 + (_l_attenuationDistance / _l_lightSource.radius));
		_l_attenuation = (_l_spotAttenuation / (_l_attDen * _l_attDen));
		_l_H = metal::normalize((_l_L + viewVector));
		_g2 = fresnelSchlick(fresnel, metal::dot(_l_H, _l_L));
		_l_F = _g2;
		_l_NdotH = metal::dot(normal, _l_H);
		_l_D = (metal::pow(_l_NdotH, _l_specularPower) * _l_specularNormalization);
		_l_accumulatedColor = (_l_accumulatedColor + (((_l_lightSource.intensity.xyz * metal::float3(_l_attenuation, _l_attenuation, _l_attenuation)) * (_l_albedoColor + (_l_F * metal::float3(_l_D, _l_D, _l_D)))) * metal::float3(_l_NdotL, _l_NdotL, _l_NdotL)));
	}
	(*color) = metal::float4(_l_accumulatedColor, albedo.w);
}

fragment _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const GlobalLightingState_block* GlobalLightingState [[buffer(4)]], metal::texture2d<float> normalTexture [[texture(1)]], metal::sampler normalSampler [[sampler(1)]], device const MaterialState_block* MaterialState [[buffer(5)]], metal::texture2d<float> albedoTexture [[texture(0)]], metal::sampler albedoSampler [[sampler(0)]], metal::texture2d<float> fresnelTexture [[texture(2)]])
{
	metal::float3 _l_t;
	metal::float3 _l_b;
	metal::float3 _l_n;
	metal::float3 _l_V;
	metal::float4 _l_albedo;
	metal::float3 _l_fresnel;
	metal::float3 _l_tangentNormal;
	metal::float3x3 _l_TBN;
	metal::float3 _l_N;
	metal::float4 _l_g50;
	metal::float4 _g3;
	metal::float4 _g4;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float2* FragmentInput_sve_texcoord = &_slvm_stagein.location1;
	thread metal::float3* FragmentInput_sve_normal = &_slvm_stagein.location3;
	thread metal::float3* FragmentInput_sve_tangent = &_slvm_stagein.location4;
	thread metal::float3* FragmentInput_sve_bitangent = &_slvm_stagein.location5;
	thread metal::float4* FragmentInput_sve_color = &_slvm_stagein.location2;
	thread metal::float3* FragmentInput_sve_position = &_slvm_stagein.location0;
	thread metal::float4* FragmentOutput_sve_color = &_slvm_stageout.location0;
	_l_t = metal::normalize((*FragmentInput_sve_tangent));
	_l_b = metal::normalize((*FragmentInput_sve_bitangent));
	_l_n = metal::normalize((*FragmentInput_sve_normal));
	_l_V = metal::normalize(-(*FragmentInput_sve_position));
	_l_albedo = ((*FragmentInput_sve_color) * albedoTexture.sample(albedoSampler, (*FragmentInput_sve_texcoord)));
	_g3 = fresnelTexture.sample(albedoSampler, (*FragmentInput_sve_texcoord));
	_l_fresnel = _g3.xyz;
	_g4 = normalTexture.sample(normalSampler, (*FragmentInput_sve_texcoord));
	_l_tangentNormal = ((_g4.wyz * metal::float3(2.0, 2.0, 2.0)) - metal::float3(1.0, 1.0, 1.0));
	_l_TBN = metal::float3x3(_l_t, _l_b, _l_n);
	_l_N = metal::normalize((_l_TBN * _l_tangentNormal));
	forwardLightingModel(&_l_g50, _l_N, _l_V, (*FragmentInput_sve_position), (_l_albedo * MaterialState->albedo), MaterialState->smoothness, _l_fresnel, GlobalLightingState);
	(*FragmentOutput_sve_color) = _l_g50;
	return _slvm_stageout;
}

