#version 420
in vec4 fColor;
in vec2 fTexcoord;

void main()
{
    gl_FragData[0] = fColor;
}
