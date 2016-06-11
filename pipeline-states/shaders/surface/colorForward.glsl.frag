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


void phongLightingModel(out vec4 color, in vec3 normal, in vec3 viewVector, in vec3 position, in vec4 albedo);

void phongLightingModel(out vec4 color, in vec3 normal, in vec3 viewVector, in vec3 position, in vec4 albedo)
{
    vec4 accumulatedColor = vec4(0.0,0.0,0.0,0.0);
    float hemiFactor = ((dot(normal,GlobalLightingState_dastrel_singleton_.sunDirection)*0.5)+0.5);
    accumulatedColor += mix(GlobalLightingState_dastrel_singleton_.groundLighting,GlobalLightingState_dastrel_singleton_.skyLighting,hemiFactor);
    for ( int i = 0; (i<GlobalLightingState_dastrel_singleton_.numberOfLights); i += 1    )
    {
        LightSource lightSource = GlobalLightingState_dastrel_singleton_.lightSources[i];
        vec3 L = (GlobalLightingState_dastrel_singleton_.lightSources[i].position.xyz-(position*lightSource.position.w));
        L = normalize(L);
        float NdotL = max(dot(normal,L),0.0);
        if ( (NdotL==0.0) )
        continue;
        accumulatedColor += (lightSource.intensity*NdotL);
    }
    color = vec4(accumulatedColor.rgb,albedo.a);
}

void main();

void main()
{
    vec3 N = normalize(FragmentInput_m_normal);
    vec3 V = normalize(FragmentInput_m_position);
    phongLightingModel(FragmentOutput_m_color, N, V, FragmentInput_m_position, FragmentInput_m_color    );
}

