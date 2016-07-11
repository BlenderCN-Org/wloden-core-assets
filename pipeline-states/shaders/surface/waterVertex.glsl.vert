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

struct WaterHarmonic
{
	vec2 centerOrDirection;
	float amplitude;
	float frequency;
	int isRadial;
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

layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 1, 1), std140 ) uniform CameraState_block
{
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

layout ( location = 2 ) in vec4 GenericVertexLayout_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 1 ) in vec2 GenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 0, 0), std140 ) uniform ObjectState_block
{
	mat4 modelMatrix;
	mat4 inverseModelMatrix;
} ObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(7, 1, 0), std140 ) uniform ObjectState_block
{
	mat4 modelMatrix;
	mat4 inverseModelMatrix;
} CameraObjectState;

layout ( location = 4 ) out vec3 VertexOutput_sve_tangent;
layout ( location = 5 ) out vec3 VertexOutput_sve_bitangent;
layout ( location = 3 ) out vec3 VertexOutput_sve_normal;
layout ( location = 0 ) out vec3 VertexOutput_sve_position;
vec3 transformNormalToView (vec3 arg1)
{
	return ((vec4(arg1, 0.0) * ObjectState.inverseModelMatrix) * CameraObjectState.modelMatrix).xyz;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraObjectState.inverseModelMatrix * (ObjectState.modelMatrix * arg1));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g5;
	_g5 = transformVector4ToView(vec4(arg1, 1.0));
	return _g5;
}

void main ()
{
	float height;
	vec3 position;
	vec2 tangentialContributions;
	int i;
	WaterHarmonic harmonic;
	float distance;
	vec2 distanceDerivatives;
	float omega;
	float kappa;
	float phase;
	vec3 tangent;
	vec3 bitangent;
	vec3 normal;
	vec4 position4;
	vec3 _g1;
	vec3 _g2;
	vec3 _g3;
	vec4 _g4;
	height = 0.0;
	position = GenericVertexLayout_sve_position;
	tangentialContributions = vec2(0.0, 0.0);
	i = 0;
	for (;(i < 5); i = (i + 1))
	{
		harmonic = MaterialState.harmonics[i];
		if ((harmonic.isRadial == 1))
		{
			distance = length((position.xz - harmonic.centerOrDirection));
			distanceDerivatives = ((position.xz - harmonic.centerOrDirection) / vec2(distance, distance));
		}
		else
		{
			distance = dot(position.xz, harmonic.centerOrDirection);
			distanceDerivatives = harmonic.centerOrDirection;
		}
		omega = (6.283185307179586 * harmonic.frequency);
		kappa = (omega / MaterialState.propagationSpeed);
		phase = ((kappa * distance) + (omega * CameraState.currentTime));
		height = (height + (harmonic.amplitude * sin(phase)));
		tangentialContributions = (tangentialContributions + (vec2(((harmonic.amplitude * kappa) * cos(phase)), ((harmonic.amplitude * kappa) * cos(phase))) * distanceDerivatives));
	}
	position = (position + vec3(0.0, height, 0.0));
	tangent = normalize(vec3(1.0, tangentialContributions.x, 0.0));
	bitangent = normalize(vec3(0.0, tangentialContributions.y, 1.0));
	normal = normalize(cross(bitangent, tangent));
	VertexOutput_sve_color = GenericVertexLayout_sve_color;
	VertexOutput_sve_texcoord = GenericVertexLayout_sve_texcoord;
	_g1 = transformNormalToView(tangent);
	VertexOutput_sve_tangent = _g1;
	_g2 = transformNormalToView(bitangent);
	VertexOutput_sve_bitangent = _g2;
	_g3 = transformNormalToView(normal);
	VertexOutput_sve_normal = _g3;
	_g4 = transformPositionToView(position);
	position4 = _g4;
	VertexOutput_sve_position = position4.xyz;
	gl_Position = (CameraState.projectionMatrix * position4);
}

