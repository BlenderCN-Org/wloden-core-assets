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
layout ( location = 1 ) in vec2 GenericVertexLayout_sve_texcoord;
layout ( location = 1 ) out vec2 VertexOutput_sve_texcoord;
layout ( location = 4 ) in vec4 GenericVertexLayout_sve_tangent4;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(5, 1, 0), std140 ) uniform CameraState_block
{
	mat4 inverseViewMatrix;
	mat4 viewMatrix;
	mat4 projectionMatrix;
	float currentTime;
} CameraState;

layout ( location = 4 ) out vec3 VertexOutput_sve_tangent;
layout ( location = 3 ) in vec3 GenericVertexLayout_sve_normal;
layout ( location = 3 ) out vec3 VertexOutput_sve_normal;
layout ( location = 5 ) out vec3 VertexOutput_sve_bitangent;
layout ( location = 0 ) in vec3 GenericVertexLayout_sve_position;
layout ( location = 0 ) out vec3 VertexOutput_sve_position;
bool isCurrentObjectInvisible ();
vec4 currentObjectColor ();
vec3 transformNormalToView (vec3 arg1);
vec4 transformVector4ToView (vec4 arg1);
vec4 transformPositionToView (vec3 arg1);
void main ();
bool isCurrentObjectInvisible ()
{
	bool _l_lorResult;
	_l_lorResult = true;
	if (!((ObjectState.objectState.visible == 0)))
		_l_lorResult = (InstanceObjectState.instanceStates[gl_InstanceID].visible == 0);
	return _l_lorResult;
}

vec4 currentObjectColor ()
{
	return (ObjectState.objectState.color * InstanceObjectState.instanceStates[gl_InstanceID].color);
}

vec3 transformNormalToView (vec3 arg1)
{
	vec4 _g4;
	_g4 = (((vec4(arg1, 0.0) * InstanceObjectState.instanceStates[gl_InstanceID].inverseMatrix) * ObjectState.objectState.inverseMatrix) * CameraState.inverseViewMatrix);
	return _g4.xyz;
}

vec4 transformVector4ToView (vec4 arg1)
{
	return (CameraState.viewMatrix * (ObjectState.objectState.matrix * (InstanceObjectState.instanceStates[gl_InstanceID].matrix * arg1)));
}

vec4 transformPositionToView (vec3 arg1)
{
	vec4 _g8;
	_g8 = transformVector4ToView(vec4(arg1, 1.0));
	return _g8;
}

void main ()
{
	vec4 _l_position4;
	bool _g1;
	vec4 _g2;
	vec3 _g3;
	vec3 _g5;
	float _g6;
	vec4 _g7;
	_g1 = isCurrentObjectInvisible();
	if (_g1)
	{
		gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
		return;
	}
	_g2 = currentObjectColor();
	VertexOutput_sve_color = (GenericVertexLayout_sve_color * _g2);
	VertexOutput_sve_texcoord = GenericVertexLayout_sve_texcoord;
	_g3 = transformNormalToView(GenericVertexLayout_sve_tangent4.xyz);
	VertexOutput_sve_tangent = _g3;
	_g5 = transformNormalToView(GenericVertexLayout_sve_normal);
	VertexOutput_sve_normal = _g5;
	_g6 = GenericVertexLayout_sve_tangent4.w;
	VertexOutput_sve_bitangent = (cross(VertexOutput_sve_normal, VertexOutput_sve_tangent) * vec3(_g6, _g6, _g6));
	_g7 = transformPositionToView(GenericVertexLayout_sve_position);
	_l_position4 = _g7;
	VertexOutput_sve_position = _l_position4.xyz;
	gl_Position = (CameraState.projectionMatrix * _l_position4);
}

