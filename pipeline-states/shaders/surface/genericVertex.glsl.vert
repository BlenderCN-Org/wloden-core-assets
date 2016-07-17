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

layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 0), std140 ) uniform ObjectState_block
{
	mat4 modelMatrix;
	mat4 inverseModelMatrix;
	vec4 color;
} ObjectState;

layout ( location = 2 ) in vec4 GenericVertexLayout_sve_color;
layout ( location = 2 ) out vec4 VertexOutput_sve_color;
layout ( location = 1 ) in vec2 GenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( location = 4 ) in vec4 GenericVertexLayout_sve_tangent4;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 1, 0), std140 ) uniform CameraObjectState_block
{
	mat4 inverseViewMatrix;
	mat4 viewMatrix;
} CameraObjectState;

layout ( location = 4 ) out vec3 VertexOutput_sve_tangent;
layout ( location = 3 ) in vec3 GenericVertexLayout_sve_normal;
layout ( location = 3 ) out vec3 VertexOutput_sve_normal;
layout ( location = 5 ) out vec3 VertexOutput_sve_bitangent;
layout ( location = 0 ) in vec3 GenericVertexLayout_sve_position;
layout ( location = 0 ) out vec3 VertexOutput_sve_position;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 1, 1), std140 ) uniform CameraState_block
{
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

vec3 transformNormalToView (vec3 arg1)
{
	return ((vec4(arg1, 0.0) * ObjectState.inverseModelMatrix) * CameraObjectState.inverseViewMatrix).xyz;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraObjectState.viewMatrix * (ObjectState.modelMatrix * arg1));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g4;
	_g4 = transformVector4ToView(vec4(arg1, 1.0));
	return _g4;
}

void main ()
{
	vec4 position4;
	vec3 _g1;
	vec3 _g2;
	vec4 _g3;
	VertexOutput_sve_color = (GenericVertexLayout_sve_color * ObjectState.color);
	VertexOutput_sve_texcoord = GenericVertexLayout_sve_texcoord;
	_g1 = transformNormalToView(GenericVertexLayout_sve_tangent4.xyz);
	VertexOutput_sve_tangent = _g1;
	_g2 = transformNormalToView(GenericVertexLayout_sve_normal);
	VertexOutput_sve_normal = _g2;
	VertexOutput_sve_bitangent = (cross(VertexOutput_sve_normal, VertexOutput_sve_tangent) * vec3(GenericVertexLayout_sve_tangent4.w, GenericVertexLayout_sve_tangent4.w, GenericVertexLayout_sve_tangent4.w));
	_g3 = transformPositionToView(GenericVertexLayout_sve_position);
	position4 = _g3;
	VertexOutput_sve_position = position4.xyz;
	gl_Position = (CameraState.projectionMatrix * position4);
}

