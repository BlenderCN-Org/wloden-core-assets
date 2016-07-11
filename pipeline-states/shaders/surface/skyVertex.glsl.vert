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

layout ( location = 0 ) in vec3 GenericVertexLayout_sve_position;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 0), std140 ) uniform ObjectState_block
{
	mat4 modelMatrix;
	mat4 inverseModelMatrix;
} ObjectState;

layout ( SLVM_GL_BINDING_VK_SET_BINDING(3, 1, 0), std140 ) uniform ObjectState_block
{
	mat4 modelMatrix;
	mat4 inverseModelMatrix;
} CameraObjectState;

layout ( location = 0 ) out vec3 VertexOutput_sve_position;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 1, 1), std140 ) uniform CameraState_block
{
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

vec4 transformPositionToWorld (vec3 arg1)
{
	return (ObjectState.modelMatrix * vec4(arg1, 1.0));
}

vec3 cameraWorldPosition ()
{
	return CameraObjectState.modelMatrix[3].xyz;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraObjectState.inverseModelMatrix * (ObjectState.modelMatrix * arg1));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g4;
	_g4 = transformVector4ToView(vec4(arg1, 1.0));
	return _g4;
}

void main ()
{
	vec4 _g1;
	vec3 _g2;
	vec4 _g3;
	_g1 = transformPositionToWorld(GenericVertexLayout_sve_position);
	_g2 = cameraWorldPosition();
	VertexOutput_sve_position = (_g1.xyz - _g2);
	_g3 = transformPositionToView(GenericVertexLayout_sve_position);
	gl_Position = (CameraState.projectionMatrix * _g3);
}

