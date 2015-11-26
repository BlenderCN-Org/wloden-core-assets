cbuffer CanvasViewport : register(b0)
{
    matrix projectionMatrix;
    matrix viewMatrix;
}

struct VertexInput
{
    float4 position : A;
    float2 texcoord : B;
    float4 color : C;
};

struct VertexOutput
{
    float4 color : COLOR;
    float2 texcoord : TEXCOORD;
    float4 position : SV_POSITION;
};

VertexOutput main(VertexInput input)
{
    VertexOutput output;
    output.color = input.color;
    output.texcoord = input.texcoord;
    output.position = mul(projectionMatrix, mul(viewMatrix, input.position));
    return output;
}
