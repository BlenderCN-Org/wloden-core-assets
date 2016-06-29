#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

struct LightSource
{
    vec4 position;
    vec4 intensity;
    vec3 spotDirection;
    float innerCosCutoff;
    float outerCosCutoff;
    float spotExponent;
    float radius;
};

layout (binding = 0, set = 0, std140) uniform ObjectState
{
    mat4 modelMatrix;
    mat4 inverseModelMatrix;
} ObjectState_dastrel_singleton_;

layout (binding = 0, set = 1, std140) uniform CameraObjectState
{
    mat4 inverseViewMatrix;
    mat4 viewMatrix;
} CameraObjectState_dastrel_singleton_;

layout (binding = 1, set = 1, std140) uniform CameraState
{
    mat4 projectionMatrix;
    float currentTime;
} CameraState_dastrel_singleton_;

layout (binding = 0, set = 2, std140) uniform GlobalLightingState
{
    vec4 groundLighting;
    vec4 skyLighting;
    vec3 sunDirection;
    int numberOfLights;
    LightSource lightSources[16];
} GlobalLightingState_dastrel_singleton_;

vec3 transformNormalToView (vec3 normal);
vec4 transformPositionToView (vec3 position);
vec4 transformVector4ToView (vec4 position);
vec4 transformPositionToWorld (vec3 position);
vec3 cameraWorldPosition ();
vec3 fresnelSchlick (vec3 F0, float cosTheta);

vec3 transformNormalToView (vec3 normal)
{
    return ((vec4(normal,0.0)*ObjectState_dastrel_singleton_.inverseModelMatrix)*CameraObjectState_dastrel_singleton_.inverseViewMatrix).xyz;
}

vec4 transformPositionToView (vec3 position)
{
    return transformVector4ToView(vec4(position,1.0));
}

vec4 transformVector4ToView (vec4 position)
{
    return (CameraObjectState_dastrel_singleton_.viewMatrix*(ObjectState_dastrel_singleton_.modelMatrix*position));
}

vec4 transformPositionToWorld (vec3 position)
{
    return (ObjectState_dastrel_singleton_.modelMatrix*vec4(position,1.0));
}

vec3 cameraWorldPosition ()
{
    return CameraObjectState_dastrel_singleton_.inverseViewMatrix[3].xyz;
}

vec3 fresnelSchlick (vec3 F0, float cosTheta)
{
    float powFactor = (1.0-cosTheta);
    float powFactor2 = (powFactor*powFactor);
    float powFactor4 = (powFactor2*powFactor2);
    float powValue = (powFactor4+powFactor);
    return (F0+((vec3(1.0,1.0,1.0)-F0)*powValue));
}

layout (binding = 1, set = 0) buffer PoseState
{
    mat4 matrices[];
} PoseState_dastrel_singleton_;

layout (location = 0) in vec3 SkinnedGenericVertexLayout_m_position;
layout (location = 1) in vec2 SkinnedGenericVertexLayout_m_texcoord;
layout (location = 2) in vec4 SkinnedGenericVertexLayout_m_color;
layout (location = 3) in vec3 SkinnedGenericVertexLayout_m_normal;
layout (location = 4) in vec4 SkinnedGenericVertexLayout_m_tangent4;
layout (location = 5) in vec4 SkinnedGenericVertexLayout_m_boneWeights;
layout (location = 6) in ivec4 SkinnedGenericVertexLayout_m_boneIndices;

layout (location = 0) out vec3 VertexOutput_m_position;
layout (location = 1) out vec2 VertexOutput_m_texcoord;
layout (location = 2) out vec4 VertexOutput_m_color;
layout (location = 3) out vec3 VertexOutput_m_normal;
layout (location = 4) out vec3 VertexOutput_m_tangent;
layout (location = 5) out vec3 VertexOutput_m_bitangent;

vec3 skinPosition (vec3 position);
vec3 skinVector (vec3 vector);

vec3 skinPosition (vec3 position)
{
    vec4 position4 = vec4(position,1.0);
    vec3 result = ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.x]*position4).xyz*SkinnedGenericVertexLayout_m_boneWeights.x);
    result += ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.y]*position4).xyz*SkinnedGenericVertexLayout_m_boneWeights.y);
    result += ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.z]*position4).xyz*SkinnedGenericVertexLayout_m_boneWeights.z);
    result += ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.w]*position4).xyz*SkinnedGenericVertexLayout_m_boneWeights.w);
    return result;
}

vec3 skinVector (vec3 vector)
{
    vec4 vector4 = vec4(vector,0.0);
    vec3 result = ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.x]*vector4).xyz*SkinnedGenericVertexLayout_m_boneWeights.x);
    result += ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.y]*vector4).xyz*SkinnedGenericVertexLayout_m_boneWeights.y);
    result += ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.z]*vector4).xyz*SkinnedGenericVertexLayout_m_boneWeights.z);
    result += ((PoseState_dastrel_singleton_.matrices[SkinnedGenericVertexLayout_m_boneIndices.w]*vector4).xyz*SkinnedGenericVertexLayout_m_boneWeights.w);
    return result;
}

void main();

void main()
{
    VertexOutput_m_color = SkinnedGenericVertexLayout_m_color;
    VertexOutput_m_texcoord = SkinnedGenericVertexLayout_m_texcoord;
    VertexOutput_m_tangent = transformNormalToView(skinVector(SkinnedGenericVertexLayout_m_tangent4.xyz));
    VertexOutput_m_normal = transformNormalToView(skinVector(SkinnedGenericVertexLayout_m_normal));
    VertexOutput_m_bitangent = (cross(VertexOutput_m_normal,VertexOutput_m_tangent)*SkinnedGenericVertexLayout_m_tangent4.w);
    vec4 position4 = transformPositionToView(skinPosition(SkinnedGenericVertexLayout_m_position));
    VertexOutput_m_position = position4.xyz;
    gl_Position = (CameraState_dastrel_singleton_.projectionMatrix*position4);
}

