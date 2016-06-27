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

layout (location = 0) in vec3 GenericVertexLayout_m_position;
layout (location = 1) in vec2 GenericVertexLayout_m_texcoord;
layout (location = 2) in vec4 GenericVertexLayout_m_color;
layout (location = 3) in vec3 GenericVertexLayout_m_normal;
layout (location = 4) in vec4 GenericVertexLayout_m_tangent4;

layout (location = 0) out vec3 VertexOutput_m_position;
layout (location = 1) out vec2 VertexOutput_m_texcoord;
layout (location = 2) out vec4 VertexOutput_m_color;
layout (location = 3) out vec3 VertexOutput_m_normal;
layout (location = 4) out vec3 VertexOutput_m_tangent;
layout (location = 5) out vec3 VertexOutput_m_bitangent;


struct WaterHarmonic
{
    vec2 centerOrDirection;
    float amplitude;
    float frequency;
    int isRadial;
};

layout (binding = 0, set = 3, std140) uniform MaterialState
{
    vec4 albedo;
    vec3 fresnel;
    float smoothness;
    float propagationSpeed;
    WaterHarmonic harmonics[5];
} MaterialState_dastrel_singleton_;

layout (binding = 2, set = 3) uniform texture2D normalTexture_dastrel_global_;
layout (binding = 1, set = 4) uniform sampler normalSampler_dastrel_global_;
layout (binding = 3, set = 3) uniform textureCube skyTexture_dastrel_global_;
layout (binding = 2, set = 4) uniform sampler skySampler_dastrel_global_;

void main();

void main()
{
    float height = 0.0;
    vec3 position = GenericVertexLayout_m_position;
    vec2 tangentialContributions = vec2(0.0,0.0);
    for ( int i = 0; (i<5); i += 1    )
    {
        WaterHarmonic harmonic = MaterialState_dastrel_singleton_.harmonics[i];
        float distance;
        vec2 distanceDerivatives;
        if ( (harmonic.isRadial==1) )
        {
            distance = length((position.xz-harmonic.centerOrDirection));
            distanceDerivatives = ((position.xz-harmonic.centerOrDirection)/distance);
        }
        else
        {
            distance = dot(position.xz,harmonic.centerOrDirection);
            distanceDerivatives = harmonic.centerOrDirection;
        }
        float omega = (6.283185307179586*harmonic.frequency);
        float kappa = (omega/MaterialState_dastrel_singleton_.propagationSpeed);
        float phase = ((kappa*distance)+(omega*CameraState_dastrel_singleton_.currentTime));
        height += (harmonic.amplitude*sin(phase));
        tangentialContributions += (((harmonic.amplitude*kappa)*cos(phase))*distanceDerivatives);
    }
    position += vec3(0.0,height,0.0);
    vec3 tangent = normalize(vec3(1.0,tangentialContributions.x,0.0));
    vec3 bitangent = normalize(vec3(0.0,tangentialContributions.y,1.0));
    vec3 normal = normalize(cross(bitangent,tangent));
    VertexOutput_m_color = GenericVertexLayout_m_color;
    VertexOutput_m_texcoord = GenericVertexLayout_m_texcoord;
    VertexOutput_m_tangent = transformNormalToView(tangent);
    VertexOutput_m_bitangent = transformNormalToView(bitangent);
    VertexOutput_m_normal = transformNormalToView(normal);
    vec4 position4 = transformPositionToView(position);
    VertexOutput_m_position = position4.xyz;
    gl_Position = (CameraState_dastrel_singleton_.projectionMatrix*position4);
}

