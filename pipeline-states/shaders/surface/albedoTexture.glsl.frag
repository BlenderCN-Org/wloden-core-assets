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

layout (binding = 0, set = 3, std140) uniform MaterialState
{
    vec4 albedo;
    vec3 fresnel;
    float smoothness;
} MaterialState_dastrel_singleton_;

layout (binding = 2, set = 3) uniform texture2D albedoTexture_dastrel_global_;
layout (binding = 3, set = 3) uniform texture2D normalTexture_dastrel_global_;
layout (binding = 4, set = 3) uniform texture2D fresnelTexture_dastrel_global_;
layout (binding = 0, set = 4) uniform sampler albedoSampler_dastrel_global_;
layout (binding = 1, set = 4) uniform sampler normalSampler_dastrel_global_;

void forwardLightingModel(out vec4 color, in vec3 normal, in vec3 viewVector, in vec3 position, in vec4 albedo, in float smoothness, in vec3 fresnel);

void forwardLightingModel(out vec4 color, in vec3 normal, in vec3 viewVector, in vec3 position, in vec4 albedo, in float smoothness, in vec3 fresnel)
{
    vec3 albedoColor = albedo.rgb;
    float specularPower = exp2((10.0*smoothness));
    float specularNormalization = ((specularPower+2.0)*0.125);
    vec3 accumulatedColor = vec3(0.0,0.0,0.0);
    float hemiFactor = ((dot(normal,GlobalLightingState_dastrel_singleton_.sunDirection)*0.5)+0.5);
    accumulatedColor += (albedoColor*mix(GlobalLightingState_dastrel_singleton_.groundLighting.rgb,GlobalLightingState_dastrel_singleton_.skyLighting.rgb,hemiFactor));
    for ( int i = 0; (i<GlobalLightingState_dastrel_singleton_.numberOfLights); i += 1    )
    {
        LightSource lightSource = GlobalLightingState_dastrel_singleton_.lightSources[i];
        vec3 L = (GlobalLightingState_dastrel_singleton_.lightSources[i].position.xyz-(position*lightSource.position.w));
        float dist = length(L);
        L = (L/dist);
        float NdotL = max(dot(normal,L),0.0);
        if ( (NdotL==0.0) )
        continue;
        float spotCos = 1.0;
        if ( (lightSource.outerCosCutoff>(-1.0)) )
        spotCos = dot(L,lightSource.spotDirection);
        if ( (spotCos<lightSource.outerCosCutoff) )
        continue;
        float spotAttenuation = (smoothstep(lightSource.outerCosCutoff,lightSource.innerCosCutoff,spotCos)*pow(spotCos,lightSource.spotExponent));
        float attenuationDistance = max(0.0,(dist-lightSource.radius));
        float attDen = (1.0+(attenuationDistance/lightSource.radius));
        float attenuation = (spotAttenuation/(attDen*attDen));
        vec3 H = normalize((L+viewVector));
        vec3 F = fresnelSchlick(fresnel,dot(H,L));
        float NdotH = dot(normal,H);
        float D = (pow(NdotH,specularPower)*specularNormalization);
        accumulatedColor += (((lightSource.intensity.rgb*attenuation)*(albedoColor+(F*D)))*NdotL);
    }
    color = vec4(accumulatedColor,albedo.a);
}

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


void main();

void main()
{
    vec3 N = normalize(FragmentInput_m_normal);
    vec3 V = normalize((-FragmentInput_m_position));
    vec4 albedo = (FragmentInput_m_color*texture(sampler2D(albedoSampler_dastrel_global_, albedoTexture_dastrel_global_), FragmentInput_m_texcoord));
    forwardLightingModel(FragmentOutput_m_color, N, V, FragmentInput_m_position, (albedo*MaterialState_dastrel_singleton_.albedo), MaterialState_dastrel_singleton_.smoothness, MaterialState_dastrel_singleton_.fresnel    );
}

