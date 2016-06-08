#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

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
} GlobalLightingState_dastrel_singleton_;


layout (binding = 0, set = 4) uniform sampler albedoSampler_dastrel_global_;
layout (binding = 1, set = 4) uniform sampler normalSampler_dastrel_global_;
layout (binding = 1, set = 4) uniform sampler displacementSampler_dastrel_global_;
layout (location = 0) in vec3 FragmentInput_m_position;
layout (location = 1) in vec2 FragmentInput_m_texcoord;
layout (location = 2) in vec4 FragmentInput_m_color;
layout (location = 3) in vec3 FragmentInput_m_normal;
layout (location = 4) in vec3 FragmentInput_m_tangent;
layout (location = 5) in vec3 FragmentInput_m_bitangent;

layout (location = 0) out vec4 FragmentOutput_m_color;


layout (binding = 0, set = 2, std140) uniform MaterialState
{
    vec4 color;
} MaterialState_dastrel_singleton_;


void main();

void main()
{
    FragmentOutput_m_color = vec4(((FragmentInput_m_normal*0.5)+0.5),1.0);
}

