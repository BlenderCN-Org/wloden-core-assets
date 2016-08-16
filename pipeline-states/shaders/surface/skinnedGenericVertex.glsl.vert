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
};

layout ( location = 2 ) in vec4 SkinnedGenericVertexLayout_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 1 ) in vec2 SkinnedGenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( location = 4 ) in vec4 SkinnedGenericVertexLayout_sve_tangent4;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 2), std430 ) buffer PoseState_bufferBlock
{
	mat4 matrices[];
} PoseState;

layout ( location = 6 ) in ivec4 SkinnedGenericVertexLayout_sve_boneIndices;
layout ( location = 5 ) in vec4 SkinnedGenericVertexLayout_sve_boneWeights;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 0, 1), std430 ) buffer InstanceObjectState_bufferBlock
{
	ObjectStateData instanceStates[];
} InstanceObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 0, 0), std140 ) uniform ObjectState_block
{
	ObjectStateData objectState;
} ObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(7, 1, 0), std140 ) uniform CameraState_block
{
	mat4 inverseViewMatrix;
	mat4 viewMatrix;
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

layout ( location = 4 ) out vec3 VertexOutput_sve_tangent;
layout ( location = 3 ) in vec3 SkinnedGenericVertexLayout_sve_normal;
layout ( location = 3 ) out vec3 VertexOutput_sve_normal;
layout ( location = 5 ) out vec3 VertexOutput_sve_bitangent;
layout ( location = 0 ) in vec3 SkinnedGenericVertexLayout_sve_position;
layout ( location = 0 ) out vec3 VertexOutput_sve_position;
vec3 skinVector (vec3 arg1)
{
	vec4 _l_vector4;
	vec3 _l_result;
	vec4 _g2;
	float _g3;
	vec4 _g4;
	float _g5;
	vec4 _g6;
	float _g7;
	vec4 _g8;
	float _g9;
	_l_vector4 = vec4(arg1, 0.0);
	_g2 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.x] * _l_vector4);
	_g3 = SkinnedGenericVertexLayout_sve_boneWeights.x;
	_l_result = (_g2.xyz * vec3(_g3, _g3, _g3));
	_g4 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.y] * _l_vector4);
	_g5 = SkinnedGenericVertexLayout_sve_boneWeights.y;
	_l_result = (_l_result + (_g4.xyz * vec3(_g5, _g5, _g5)));
	_g6 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.z] * _l_vector4);
	_g7 = SkinnedGenericVertexLayout_sve_boneWeights.z;
	_l_result = (_l_result + (_g6.xyz * vec3(_g7, _g7, _g7)));
	_g8 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.w] * _l_vector4);
	_g9 = SkinnedGenericVertexLayout_sve_boneWeights.w;
	_l_result = (_l_result + (_g8.xyz * vec3(_g9, _g9, _g9)));
	return _l_result;
}

vec3 transformNormalToView (vec3 arg1)
{
	vec4 _g11;
	_g11 = (((vec4(arg1, 0.0) * InstanceObjectState.instanceStates[gl_InstanceID].inverseMatrix) * ObjectState.objectState.inverseMatrix) * CameraState.inverseViewMatrix);
	return _g11.xyz;
}

vec3 skinPosition (vec3 arg1)
{
	vec4 _l_position4;
	vec3 _l_result;
	vec4 _g16;
	float _g17;
	vec4 _g18;
	float _g19;
	vec4 _g20;
	float _g21;
	vec4 _g22;
	float _g23;
	_l_position4 = vec4(arg1, 1.0);
	_g16 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.x] * _l_position4);
	_g17 = SkinnedGenericVertexLayout_sve_boneWeights.x;
	_l_result = (_g16.xyz * vec3(_g17, _g17, _g17));
	_g18 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.y] * _l_position4);
	_g19 = SkinnedGenericVertexLayout_sve_boneWeights.y;
	_l_result = (_l_result + (_g18.xyz * vec3(_g19, _g19, _g19)));
	_g20 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.z] * _l_position4);
	_g21 = SkinnedGenericVertexLayout_sve_boneWeights.z;
	_l_result = (_l_result + (_g20.xyz * vec3(_g21, _g21, _g21)));
	_g22 = (PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.w] * _l_position4);
	_g23 = SkinnedGenericVertexLayout_sve_boneWeights.w;
	_l_result = (_l_result + (_g22.xyz * vec3(_g23, _g23, _g23)));
	return _l_result;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraState.viewMatrix * (ObjectState.objectState.matrix * (InstanceObjectState.instanceStates[gl_InstanceID].matrix * arg1)));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g25;
	_g25 = transformVector4ToView(vec4(arg1, 1.0));
	return _g25;
}

void main ()
{
	vec4 _l_position4;
	vec3 _g1;
	vec3 _g10;
	vec3 _g12;
	vec3 _g13;
	float _g14;
	vec3 _g15;
	vec4 _g24;
	VertexOutput_sve_color = SkinnedGenericVertexLayout_sve_color;
	VertexOutput_sve_texcoord = SkinnedGenericVertexLayout_sve_texcoord;
	_g1 = skinVector(SkinnedGenericVertexLayout_sve_tangent4.xyz);
	_g10 = transformNormalToView(_g1);
	VertexOutput_sve_tangent = _g10;
	_g12 = skinVector(SkinnedGenericVertexLayout_sve_normal);
	_g13 = transformNormalToView(_g12);
	VertexOutput_sve_normal = _g13;
	_g14 = SkinnedGenericVertexLayout_sve_tangent4.w;
	VertexOutput_sve_bitangent = (cross(VertexOutput_sve_normal, VertexOutput_sve_tangent) * vec3(_g14, _g14, _g14));
	_g15 = skinPosition(SkinnedGenericVertexLayout_sve_position);
	_g24 = transformPositionToView(_g15);
	_l_position4 = _g24;
	VertexOutput_sve_position = _l_position4.xyz;
	gl_Position = (CameraState.projectionMatrix * _l_position4);
}

