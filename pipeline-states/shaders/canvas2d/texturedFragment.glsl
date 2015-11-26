#version 420
#pragma agpu sampler_binding diffuseTexture 0

uniform sampler2D diffuseTexture;

in vec2 fTexcoord;
in vec4 fColor;

void main()
{
    gl_FragData[0] = fColor*texture2D(diffuseTexture, fTexcoord);
}
