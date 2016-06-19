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

layout (location = 0) in vec2 VertexInput_m_position;
layout (location = 1) in vec2 VertexInput_m_texcoord;
layout (location = 2) in vec4 VertexInput_m_color;

layout (location = 0) out vec4 VertexOutput_m_position;
layout (location = 1) out vec2 VertexOutput_m_texcoord;
layout (location = 2) out vec4 VertexOutput_m_color;


void main();

void main()
{
    VertexOutput_m_color = VertexInput_m_color;
    VertexOutput_m_texcoord = VertexInput_m_texcoord;
    VertexOutput_m_position = (CanvasViewport_dastrel_singleton_.viewMatrix*vec4(VertexInput_m_position,0.0,1.0));
    gl_Position = (CanvasViewport_dastrel_singleton_.projectionMatrix*VertexOutput_m_position);
}

