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

struct LightSource
{
	vec4 position;
	vec4 intensity;
	vec3 spotDirection;
	float innerCosCutoff;
	float outerCosCutoff;
	float spotExponent;
	float radius;
};

layout ( location = 3 ) in vec3 FragmentInput_sve_normal;
layout ( location = 0 ) in vec3 FragmentInput_sve_position;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 3, 2) ) uniform SLVM_TEXTURE(texture2D, sampler2D) albedoTexture;
layout ( location = 1 ) in vec2 FragmentInput_sve_texcoord;
SLVM_VK_UNIFORM_SAMPLER( ( SLVM_GL_BINDING_VK_SET_BINDING(2, 4, 0) ) ,albedoSampler)
layout ( location = 2 ) in vec4 FragmentInput_sve_color;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(4, 3, 0), std140 ) uniform MaterialState_block
{
	vec4 albedo;
	vec3 fresnel;
	float smoothness;
} MaterialState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(6, 2, 0), std140 ) uniform GlobalLightingState_block
{
	vec4 groundLighting;
	vec4 skyLighting;
	vec3 sunDirection;
	int numberOfLights;
	LightSource lightSources[16];
} GlobalLightingState;

layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
vec3 fresnelSchlick (vec3 arg1, float arg2)
{
	float _l_powFactor;
	float _l_powFactor2;
	float _l_powFactor4;
	float _l_powValue;
	_l_powFactor = (1.0 - arg2);
	_l_powFactor2 = (_l_powFactor * _l_powFactor);
	_l_powFactor4 = (_l_powFactor2 * _l_powFactor2);
	_l_powValue = (_l_powFactor4 * _l_powFactor);
	return (arg1 + ((vec3(1.0, 1.0, 1.0) - arg1) * vec3(_l_powValue, _l_powValue, _l_powValue)));
}

void forwardLightingModel (inout vec4 color, vec3 normal, vec3 viewVector, vec3 position, vec4 albedo, float smoothness, vec3 fresnel)
{
	vec3 _l_albedoColor;
	float _l_specularPower;
	float _l_specularNormalization;
	vec3 _l_accumulatedColor;
	float _l_hemiFactor;
	int _l_i;
	LightSource _l_lightSource;
	vec3 _l_L;
	float _l_dist;
	float _l_NdotL;
	float _l_spotCos;
	float _l_spotAttenuation;
	float _l_attenuationDistance;
	float _l_attDen;
	float _l_attenuation;
	vec3 _l_H;
	vec3 _l_F;
	float _l_NdotH;
	float _l_D;
	float _g1;
	vec3 _g2;
	_l_albedoColor = albedo.xyz;
	_l_specularPower = exp2((10.0 * smoothness));
	_l_specularNormalization = ((_l_specularPower + 2.0) * 0.125);
	_l_accumulatedColor = vec3(0.0, 0.0, 0.0);
	_l_hemiFactor = ((dot(normal, GlobalLightingState.sunDirection) * 0.5) + 0.5);
	_l_accumulatedColor = (_l_accumulatedColor + (_l_albedoColor * mix(GlobalLightingState.groundLighting.xyz, GlobalLightingState.skyLighting.xyz, vec3(_l_hemiFactor, _l_hemiFactor, _l_hemiFactor))));
	_l_i = 0;
	for (;(_l_i < GlobalLightingState.numberOfLights); _l_i = (_l_i + 1))
	{
		_l_lightSource = GlobalLightingState.lightSources[_l_i];
		_g1 = _l_lightSource.position.w;
		_l_L = (GlobalLightingState.lightSources[_l_i].position.xyz - (position * vec3(_g1, _g1, _g1)));
		_l_dist = length(_l_L);
		_l_L = (_l_L / vec3(_l_dist, _l_dist, _l_dist));
		_l_NdotL = max(dot(normal, _l_L), 0.0);
		if ((_l_NdotL == 0.0))
			continue;
		_l_spotCos = 1.0;
		if ((_l_lightSource.outerCosCutoff > -1.0))
			_l_spotCos = dot(_l_L, _l_lightSource.spotDirection);
		if ((_l_spotCos < _l_lightSource.outerCosCutoff))
			continue;
		_l_spotAttenuation = (smoothstep(_l_lightSource.outerCosCutoff, _l_lightSource.innerCosCutoff, _l_spotCos) * pow(_l_spotCos, _l_lightSource.spotExponent));
		_l_attenuationDistance = max(0.0, (_l_dist - _l_lightSource.radius));
		_l_attDen = (1.0 + (_l_attenuationDistance / _l_lightSource.radius));
		_l_attenuation = (_l_spotAttenuation / (_l_attDen * _l_attDen));
		_l_H = normalize((_l_L + viewVector));
		_g2 = fresnelSchlick(fresnel, dot(_l_H, _l_L));
		_l_F = _g2;
		_l_NdotH = dot(normal, _l_H);
		_l_D = (pow(_l_NdotH, _l_specularPower) * _l_specularNormalization);
		_l_accumulatedColor = (_l_accumulatedColor + (((_l_lightSource.intensity.xyz * vec3(_l_attenuation, _l_attenuation, _l_attenuation)) * (_l_albedoColor + (_l_F * vec3(_l_D, _l_D, _l_D)))) * vec3(_l_NdotL, _l_NdotL, _l_NdotL)));
	}
	color = vec4(_l_accumulatedColor, albedo.w);
}

void main ()
{
	vec3 _l_N;
	vec3 _l_V;
	vec4 _l_albedo;
	vec4 _l_g16;
	_l_N = normalize(FragmentInput_sve_normal);
	_l_V = normalize(-FragmentInput_sve_position);
	_l_albedo = (FragmentInput_sve_color * texture(SLVM_COMBINE_SAMPLER_WITH(albedoSampler, albedoTexture, sampler2D), FragmentInput_sve_texcoord));
	forwardLightingModel(_l_g16, _l_N, _l_V, FragmentInput_sve_position, (_l_albedo * MaterialState.albedo), MaterialState.smoothness, MaterialState.fresnel);
	FragmentOutput_sve_color = _l_g16;
}

