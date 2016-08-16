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

struct WaterHarmonic
{
	vec2 centerOrDirection;
	float amplitude;
	float frequency;
	int isRadial;
};

struct ObjectStateData
{
	mat4 matrix;
	mat4 inverseMatrix;
	vec4 color;
};

layout ( location = 0 ) in vec3 GenericVertexLayout_sve_position;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 3, 0), std140 ) uniform MaterialState_block
{
	vec4 albedo;
	vec3 fresnel;
	float smoothness;
	float propagationSpeed;
	WaterHarmonic harmonics[5];
} MaterialState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 1, 0), std140 ) uniform CameraState_block
{
	mat4 inverseViewMatrix;
	mat4 viewMatrix;
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

layout ( location = 2 ) in vec4 GenericVertexLayout_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 1 ) in vec2 GenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 0, 1), std430 ) buffer InstanceObjectState_bufferBlock
{
	ObjectStateData instanceStates[];
} InstanceObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(7, 0, 0), std140 ) uniform ObjectState_block
{
	ObjectStateData objectState;
} ObjectState;

layout ( location = 4 ) out vec3 VertexOutput_sve_tangent;
layout ( location = 5 ) out vec3 VertexOutput_sve_bitangent;
layout ( location = 3 ) out vec3 VertexOutput_sve_normal;
layout ( location = 0 ) out vec3 VertexOutput_sve_position;
vec3 transformNormalToView (vec3 arg1)
{
	vec4 _g3;
	_g3 = (((vec4(arg1, 0.0) * InstanceObjectState.instanceStates[gl_InstanceID].inverseMatrix) * ObjectState.objectState.inverseMatrix) * CameraState.inverseViewMatrix);
	return _g3.xyz;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraState.viewMatrix * (ObjectState.objectState.matrix * (InstanceObjectState.instanceStates[gl_InstanceID].matrix * arg1)));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g7;
	_g7 = transformVector4ToView(vec4(arg1, 1.0));
	return _g7;
}

void main ()
{
	float _l_height;
	vec3 _l_position;
	vec2 _l_tangentialContributions;
	int _l_i;
	WaterHarmonic _l_harmonic;
	float _l_distance;
	vec2 _l_distanceDerivatives;
	float _l_omega;
	float _l_kappa;
	float _l_phase;
	vec3 _l_tangent;
	vec3 _l_bitangent;
	vec3 _l_normal;
	vec4 _l_position4;
	float _g1;
	vec3 _g2;
	vec3 _g4;
	vec3 _g5;
	vec4 _g6;
	_l_height = 0.0;
	_l_position = GenericVertexLayout_sve_position;
	_l_tangentialContributions = vec2(0.0, 0.0);
	_l_i = 0;
	for (;(_l_i < 5); _l_i = (_l_i + 1))
	{
		_l_harmonic = MaterialState.harmonics[_l_i];
		if ((_l_harmonic.isRadial == 1))
		{
			_l_distance = length((_l_position.xz - _l_harmonic.centerOrDirection));
			_l_distanceDerivatives = ((_l_position.xz - _l_harmonic.centerOrDirection) / vec2(_l_distance, _l_distance));
		}
		else
		{
			_l_distance = dot(_l_position.xz, _l_harmonic.centerOrDirection);
			_l_distanceDerivatives = _l_harmonic.centerOrDirection;
		}
		_l_omega = (6.283185307179586 * _l_harmonic.frequency);
		_l_kappa = (_l_omega / MaterialState.propagationSpeed);
		_l_phase = ((_l_kappa * _l_distance) + (_l_omega * CameraState.currentTime));
		_l_height = (_l_height + (_l_harmonic.amplitude * sin(_l_phase)));
		_g1 = ((_l_harmonic.amplitude * _l_kappa) * cos(_l_phase));
		_l_tangentialContributions = (_l_tangentialContributions + (vec2(_g1, _g1) * _l_distanceDerivatives));
	}
	_l_position = (_l_position + vec3(0.0, _l_height, 0.0));
	_l_tangent = normalize(vec3(1.0, _l_tangentialContributions.x, 0.0));
	_l_bitangent = normalize(vec3(0.0, _l_tangentialContributions.y, 1.0));
	_l_normal = normalize(cross(_l_bitangent, _l_tangent));
	VertexOutput_sve_color = GenericVertexLayout_sve_color;
	VertexOutput_sve_texcoord = GenericVertexLayout_sve_texcoord;
	_g2 = transformNormalToView(_l_tangent);
	VertexOutput_sve_tangent = _g2;
	_g4 = transformNormalToView(_l_bitangent);
	VertexOutput_sve_bitangent = _g4;
	_g5 = transformNormalToView(_l_normal);
	VertexOutput_sve_normal = _g5;
	_g6 = transformPositionToView(_l_position);
	_l_position4 = _g6;
	VertexOutput_sve_position = _l_position4.xyz;
	gl_Position = (CameraState.projectionMatrix * _l_position4);
}

