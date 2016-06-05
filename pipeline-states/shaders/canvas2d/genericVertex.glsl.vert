#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (set = 0, binding = 0, std140) uniform CanvasViewport
{
    mat4 projectionMatrix;
    mat4 viewMatrix;
} CanvasViewport_dastrel_singleton_;


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

