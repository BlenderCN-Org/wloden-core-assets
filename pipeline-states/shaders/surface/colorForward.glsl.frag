#version 430
#extension GL_ARB_separate_shader_objects : enable

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
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 3, 0), std140 ) uniform MaterialState_block
{
	vec4 albedo;
	vec3 fresnel;
	float smoothness;
} MaterialState;

layout ( location = 2 ) in vec4 FragmentInput_sve_color;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 2, 0), std140 ) uniform GlobalLightingState_block
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
	float powFactor;
	float powFactor2;
	float powFactor4;
	float powValue;
	powFactor = (1.0 - arg2);
	powFactor2 = (powFactor * powFactor);
	powFactor4 = (powFactor2 * powFactor2);
	powValue = (powFactor4 * powFactor);
	return (arg1 + ((vec3(1.0, 1.0, 1.0) - arg1) * vec3(powValue, powValue, powValue)));
}

void forwardLightingModel (inout vec4 color, vec3 normal, vec3 viewVector, vec3 position, vec4 albedo, float smoothness, vec3 fresnel)
{
	vec3 albedoColor;
	float specularPower;
	float specularNormalization;
	vec3 accumulatedColor;
	float hemiFactor;
	int i;
	LightSource lightSource;
	vec3 L;
	float dist;
	float NdotL;
	float spotCos;
	float spotAttenuation;
	float attenuationDistance;
	float attDen;
	float attenuation;
	vec3 H;
	vec3 F;
	float NdotH;
	float D;
	vec3 _g1;
	albedoColor = albedo.xyz;
	specularPower = exp2((10.0 * smoothness));
	specularNormalization = ((specularPower + 2.0) * 0.125);
	accumulatedColor = vec3(0.0, 0.0, 0.0);
	hemiFactor = ((dot(normal, GlobalLightingState.sunDirection) * 0.5) + 0.5);
	accumulatedColor = (accumulatedColor + (albedoColor * mix(GlobalLightingState.groundLighting.xyz, GlobalLightingState.skyLighting.xyz, vec3(hemiFactor, hemiFactor, hemiFactor))));
	i = 0;
	for (;(i < GlobalLightingState.numberOfLights); i = (i + 1))
	{
		lightSource = GlobalLightingState.lightSources[i];
		L = (GlobalLightingState.lightSources[i].position.xyz - (position * vec3(lightSource.position.w, lightSource.position.w, lightSource.position.w)));
		dist = length(L);
		L = (L / vec3(dist, dist, dist));
		NdotL = max(dot(normal, L), 0.0);
		if ((NdotL == 0.0))
			continue;
		spotCos = 1.0;
		if ((lightSource.outerCosCutoff > -1.0))
			spotCos = dot(L, lightSource.spotDirection);
		if ((spotCos < lightSource.outerCosCutoff))
			continue;
		spotAttenuation = (smoothstep(lightSource.outerCosCutoff, lightSource.innerCosCutoff, spotCos) * pow(spotCos, lightSource.spotExponent));
		attenuationDistance = max(0.0, (dist - lightSource.radius));
		attDen = (1.0 + (attenuationDistance / lightSource.radius));
		attenuation = (spotAttenuation / (attDen * attDen));
		H = normalize((L + viewVector));
		_g1 = fresnelSchlick(fresnel, dot(H, L));
		F = _g1;
		NdotH = dot(normal, H);
		D = (pow(NdotH, specularPower) * specularNormalization);
		accumulatedColor = (accumulatedColor + (((lightSource.intensity.xyz * vec3(attenuation, attenuation, attenuation)) * (albedoColor + (F * vec3(D, D, D)))) * vec3(NdotL, NdotL, NdotL)));
	}
	color = vec4(accumulatedColor, albedo.w);
}

void main ()
{
	vec3 N;
	vec3 V;
	vec4 g8;
	N = normalize(FragmentInput_sve_normal);
	V = normalize(-FragmentInput_sve_position);
	forwardLightingModel(g8, N, V, FragmentInput_sve_position, (FragmentInput_sve_color * MaterialState.albedo), MaterialState.smoothness, MaterialState.fresnel);
	FragmentOutput_sve_color = g8;
}

