#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

struct ColorRampEntry
{
    float edge;
    vec4 color;
};

layout (binding = 0, set = 0, std140) uniform CanvasViewport
{
    mat4 projectionMatrix;
    mat4 viewMatrix;
} CanvasViewport_dastrel_singleton_;

layout (push_constant) uniform CurrentColorRamp
{
    int colorRampIndex;
    int colorRampSize;
} CurrentColorRamp_dastrel_singleton_;

layout (binding = 1, set = 0) buffer ColorRamps
{
    ColorRampEntry entries[];
} ColorRamps_dastrel_singleton_;

vec4 evaluateColorRamp (float coord);

vec4 evaluateColorRamp (float coord)
{
    if ( (CurrentColorRamp_dastrel_singleton_.colorRampSize==0) )
    return vec4(1.0,1.0,1.0,1.0);
    ColorRampEntry lastEntry = ColorRamps_dastrel_singleton_.entries[CurrentColorRamp_dastrel_singleton_.colorRampIndex];
    ColorRampEntry newEntry = lastEntry;
    for ( int i = 1; (i<CurrentColorRamp_dastrel_singleton_.colorRampSize); i += 1    )
    {
        newEntry = ColorRamps_dastrel_singleton_.entries[(CurrentColorRamp_dastrel_singleton_.colorRampIndex+i)];
        if ( (newEntry.edge>coord) )
        break;
        lastEntry = newEntry;
    }
    float delta = (newEntry.edge-lastEntry.edge);
    if ( (delta<0.0001) )
    return newEntry.color;
    return mix(lastEntry.color,newEntry.color,((coord-lastEntry.edge)/delta));
}

layout (binding = 0, set = 1) uniform texture2D mainTexture_dastrel_global_;
layout (binding = 0, set = 2) uniform texture2D fontTexture_dastrel_global_;
layout (binding = 0, set = 3) uniform sampler mainSampler_dastrel_global_;
layout (binding = 1, set = 3) uniform sampler fontSampler_dastrel_global_;
layout (location = 0) in vec4 FragmentInput_m_position;
layout (location = 1) in vec2 FragmentInput_m_texcoord;
layout (location = 2) in vec4 FragmentInput_m_color;

layout (location = 0) out vec4 FragmentOutput_m_color;


void main();

void main()
{
    FragmentOutput_m_color = (FragmentInput_m_color*evaluateColorRamp(0.5));
}

