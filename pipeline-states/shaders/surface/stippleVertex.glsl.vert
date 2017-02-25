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

struct ObjectStateData
{
	mat4 matrix;
	mat4 inverseMatrix;
	vec4 color;
	int visible;
};

layout ( location = 1 ) in vec2 GenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 0), std140 ) uniform ObjectState_block
{
	ObjectStateData objectState;
} ObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 0, 1), std430 ) buffer InstanceObjectState_bufferBlock
{
	ObjectStateData instanceStates[];
} InstanceObjectState;

layout ( location = 2 ) in vec4 GenericVertexLayout_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 0 ) in vec3 GenericVertexLayout_sve_position;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 1, 0), std140 ) uniform CameraState_block
{
	mat4 inverseViewMatrix;
	mat4 viewMatrix;
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

layout ( location = 0 ) out vec3 VertexOutput_sve_position;
vec4 currentObjectColor ();
vec4 transformVector4ToView (vec4 arg1);
vec4 transformPositionToView (vec3 arg1);
vec3 transformVectorToWorld (vec3 arg1);
void main ();
vec4 currentObjectColor ()
{
	return (ObjectState.objectState.color * InstanceObjectState.instanceStates[gl_InstanceIndex].color);
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraState.viewMatrix * (ObjectState.objectState.matrix * (InstanceObjectState.instanceStates[gl_InstanceIndex].matrix * arg1)));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g3;
	_g3 = transformVector4ToView(vec4(arg1, 1.0));
	return _g3;
}

vec3 transformVectorToWorld (vec3 arg1)
{
	vec4 _g5;
	_g5 = (ObjectState.objectState.matrix * (InstanceObjectState.instanceStates[gl_InstanceIndex].matrix * vec4(arg1, 0.0)));
	return _g5.xyz;
}

void main ()
{
	vec4 _l_position4;
	vec4 _g1;
	vec4 _g2;
	vec3 _g4;
	VertexOutput_sve_texcoord = GenericVertexLayout_sve_texcoord;
	_g1 = currentObjectColor();
	VertexOutput_sve_color = (GenericVertexLayout_sve_color * _g1);
	_g2 = transformPositionToView(GenericVertexLayout_sve_position);
	_l_position4 = _g2;
	_g4 = transformVectorToWorld(GenericVertexLayout_sve_position);
	VertexOutput_sve_position = _g4;
	gl_Position = (CameraState.projectionMatrix * _l_position4);
}

