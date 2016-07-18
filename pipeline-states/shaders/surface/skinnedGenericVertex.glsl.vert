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

layout ( location = 2 ) in vec4 SkinnedGenericVertexLayout_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 1 ) in vec2 SkinnedGenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( location = 4 ) in vec4 SkinnedGenericVertexLayout_sve_tangent4;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 1), std430 ) buffer PoseState_bufferBlock
{
	mat4 matrices[];
} PoseState;

layout ( location = 6 ) in ivec4 SkinnedGenericVertexLayout_sve_boneIndices;
layout ( location = 5 ) in vec4 SkinnedGenericVertexLayout_sve_boneWeights;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 0, 0), std140 ) uniform ObjectState_block
{
	mat4 modelMatrix;
	mat4 inverseModelMatrix;
	vec4 color;
} ObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 1, 0), std140 ) uniform CameraState_block
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
	vec4 vector4;
	vec3 result;
	vector4 = vec4(arg1, 0.0);
	result = ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.x] * vector4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.x, SkinnedGenericVertexLayout_sve_boneWeights.x, SkinnedGenericVertexLayout_sve_boneWeights.x));
	result = (result + ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.y] * vector4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.y, SkinnedGenericVertexLayout_sve_boneWeights.y, SkinnedGenericVertexLayout_sve_boneWeights.y)));
	result = (result + ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.z] * vector4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.z, SkinnedGenericVertexLayout_sve_boneWeights.z, SkinnedGenericVertexLayout_sve_boneWeights.z)));
	result = (result + ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.w] * vector4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.w, SkinnedGenericVertexLayout_sve_boneWeights.w, SkinnedGenericVertexLayout_sve_boneWeights.w)));
	return result;
}

vec3 transformNormalToView (vec3 arg1)
{
	return ((vec4(arg1, 0.0) * ObjectState.inverseModelMatrix) * CameraState.inverseViewMatrix).xyz;
}

vec3 skinPosition (vec3 arg1)
{
	vec4 position4;
	vec3 result;
	position4 = vec4(arg1, 1.0);
	result = ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.x] * position4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.x, SkinnedGenericVertexLayout_sve_boneWeights.x, SkinnedGenericVertexLayout_sve_boneWeights.x));
	result = (result + ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.y] * position4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.y, SkinnedGenericVertexLayout_sve_boneWeights.y, SkinnedGenericVertexLayout_sve_boneWeights.y)));
	result = (result + ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.z] * position4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.z, SkinnedGenericVertexLayout_sve_boneWeights.z, SkinnedGenericVertexLayout_sve_boneWeights.z)));
	result = (result + ((PoseState.matrices[SkinnedGenericVertexLayout_sve_boneIndices.w] * position4).xyz * vec3(SkinnedGenericVertexLayout_sve_boneWeights.w, SkinnedGenericVertexLayout_sve_boneWeights.w, SkinnedGenericVertexLayout_sve_boneWeights.w)));
	return result;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraState.viewMatrix * (ObjectState.modelMatrix * arg1));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g7;
	_g7 = transformVector4ToView(vec4(arg1, 1.0));
	return _g7;
}

void main ()
{
	vec4 position4;
	vec3 _g1;
	vec3 _g2;
	vec3 _g3;
	vec3 _g4;
	vec3 _g5;
	vec4 _g6;
	VertexOutput_sve_color = SkinnedGenericVertexLayout_sve_color;
	VertexOutput_sve_texcoord = SkinnedGenericVertexLayout_sve_texcoord;
	_g1 = skinVector(SkinnedGenericVertexLayout_sve_tangent4.xyz);
	_g2 = transformNormalToView(_g1);
	VertexOutput_sve_tangent = _g2;
	_g3 = skinVector(SkinnedGenericVertexLayout_sve_normal);
	_g4 = transformNormalToView(_g3);
	VertexOutput_sve_normal = _g4;
	VertexOutput_sve_bitangent = (cross(VertexOutput_sve_normal, VertexOutput_sve_tangent) * vec3(SkinnedGenericVertexLayout_sve_tangent4.w, SkinnedGenericVertexLayout_sve_tangent4.w, SkinnedGenericVertexLayout_sve_tangent4.w));
	_g5 = skinPosition(SkinnedGenericVertexLayout_sve_position);
	_g6 = transformPositionToView(_g5);
	position4 = _g6;
	VertexOutput_sve_position = position4.xyz;
	gl_Position = (CameraState.projectionMatrix * position4);
}

