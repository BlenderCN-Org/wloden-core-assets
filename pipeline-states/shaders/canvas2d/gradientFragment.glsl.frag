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
    int a = 0;
    int b = CurrentColorRamp_dastrel_singleton_.colorRampSize;
    int lastResult = a;
    while ( (a<b) )
    {
        int m = ((a+b)/2);
        if ( (ColorRamps_dastrel_singleton_.entries[(CurrentColorRamp_dastrel_singleton_.colorRampIndex+m)].edge<=coord) )
        {
            lastResult = m;
            a = (m+1);
        }
        else
        {
            b = m;
        }
    }
    int entryIndex = (CurrentColorRamp_dastrel_singleton_.colorRampIndex+lastResult);
    float prevEdge = ColorRamps_dastrel_singleton_.entries[entryIndex].edge;
    if ( (((lastResult==0)&&(coord<=prevEdge))||(lastResult==(CurrentColorRamp_dastrel_singleton_.colorRampSize-1))) )
    return ColorRamps_dastrel_singleton_.entries[entryIndex].color;
    float nextEdge = ColorRamps_dastrel_singleton_.entries[(entryIndex+1)].edge;
    float mixFactor = ((coord-prevEdge)/(nextEdge-prevEdge));
    return mix(ColorRamps_dastrel_singleton_.entries[entryIndex].color,ColorRamps_dastrel_singleton_.entries[(entryIndex+1)].color,mixFactor);
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
    float coord;
    vec2 point = FragmentInput_m_position.xy;
    if ( (FragmentInput_m_texcoord.x==0.0) )
    {
        vec2 start = FragmentInput_m_color.xy;
        vec2 end = FragmentInput_m_color.zw;
        vec2 delta = (end-start);
        coord = (dot(delta,(point-start))/dot(delta,delta));
    }
    else
    {
        vec2 center = FragmentInput_m_color.xy;
        vec2 focalPoint = FragmentInput_m_color.zw;
        float radius = FragmentInput_m_texcoord.y;
        vec2 delta = (point-focalPoint);
        vec2 focalDelta = (center-focalPoint);
        float E = ((delta.x*focalDelta.y)-(delta.y*focalDelta.x));
        float r2 = (radius*radius);
        coord = ((dot(delta,focalDelta)+sqrt(((r2*dot(delta,delta))-(E*E))))/(r2-dot(focalDelta,focalDelta)));
    }
    FragmentOutput_m_color = evaluateColorRamp(coord);
}
