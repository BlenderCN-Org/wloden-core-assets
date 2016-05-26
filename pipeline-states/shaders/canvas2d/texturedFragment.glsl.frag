#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (set = 0, binding = 0, std140) uniform CanvasViewport
{
    mat4 projectionMatrix;
    mat4 viewMatrix;
} CanvasViewport_dastrel_singleton_;


layout (binding = 0, set = 1) uniform texture2D mainTexture_dastrel_global_;
layout (binding = 0, set = 2) uniform texture2D fontTexture_dastrel_global_;
layout (set = 3, binding = 0) uniform sampler mainSampler_dastrel_global_;
layout (binding = 1, set = 3) uniform sampler fontSampler_dastrel_global_;
layout (location = 0) in vec4 FragmentInput_m_position;
layout (location = 1) in vec2 FragmentInput_m_texcoord;
layout (location = 2) in vec4 FragmentInput_m_color;

layout (location = 0) out vec4 FragmentOutput_m_color;


void main();

void main()
{
    FragmentOutput_m_color = (FragmentInput_m_color*texture(sampler2D(mainSampler_dastrel_global_, mainTexture_dastrel_global_), FragmentInput_m_texcoord));
}

