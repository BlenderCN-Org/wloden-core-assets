#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

struct LightSource
{
    vec4 position;
    vec4 intensity;
};

layout (binding = 0, set = 0, std140) uniform ObjectState
{
    mat4 modelMatrix;
    mat4 inverseModelMatrix;
    mat3 normalMatrix;
    mat3 inverseNormalMatrix;
} ObjectState_dastrel_singleton_;

layout (binding = 0, set = 1, std140) uniform CameraObjectState
{
    mat4 inverseViewMatrix;
    mat4 viewMatrix;
    mat3 inverseViewNormalMatrix;
    mat3 viewNormalMatrix;
} CameraObjectState_dastrel_singleton_;

layout (binding = 1, set = 1, std140) uniform CameraState
{
    mat4 projectionMatrix;
    mat4 inverseProjectionMatrix;
} CameraState_dastrel_singleton_;

layout (binding = 0, set = 2, std140) uniform GlobalLightingState
{
    vec4 groundLighting;
    vec4 skyLighting;
    vec3 sunDirection;
    int numberOfLights;
    LightSource lightSources[16];
} GlobalLightingState_dastrel_singleton_;


layout (location = 0) in vec3 GenericVertexLayout_m_position;
layout (location = 1) in vec2 GenericVertexLayout_m_texcoord;
layout (location = 2) in vec4 GenericVertexLayout_m_color;
layout (location = 3) in vec3 GenericVertexLayout_m_normal;
layout (location = 4) in vec3 GenericVertexLayout_m_tangent;
layout (location = 5) in vec3 GenericVertexLayout_m_bitangent;

layout (location = 0) out vec3 VertexOutput_m_position;
layout (location = 1) out vec2 VertexOutput_m_texcoord;
layout (location = 2) out vec4 VertexOutput_m_color;
layout (location = 3) out vec3 VertexOutput_m_normal;
layout (location = 4) out vec3 VertexOutput_m_tangent;
layout (location = 5) out vec3 VertexOutput_m_bitangent;


void main();

void main()
{
    VertexOutput_m_color = GenericVertexLayout_m_color;
    VertexOutput_m_texcoord = GenericVertexLayout_m_texcoord;
    VertexOutput_m_tangent = ((CameraObjectState_dastrel_singleton_.viewNormalMatrix*ObjectState_dastrel_singleton_.normalMatrix)*GenericVertexLayout_m_tangent);
    VertexOutput_m_bitangent = ((CameraObjectState_dastrel_singleton_.viewNormalMatrix*ObjectState_dastrel_singleton_.normalMatrix)*GenericVertexLayout_m_bitangent);
    VertexOutput_m_normal = ((CameraObjectState_dastrel_singleton_.viewNormalMatrix*ObjectState_dastrel_singleton_.normalMatrix)*GenericVertexLayout_m_normal);
    vec4 position4 = ((CameraObjectState_dastrel_singleton_.viewMatrix*ObjectState_dastrel_singleton_.modelMatrix)*vec4(GenericVertexLayout_m_position,1.0));
    VertexOutput_m_position = position4.xyz;
    gl_Position = (CameraState_dastrel_singleton_.projectionMatrix*position4);
}

