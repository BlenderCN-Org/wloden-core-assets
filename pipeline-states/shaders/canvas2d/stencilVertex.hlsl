cbuffer CanvasViewport : register(b0)
{
    matrix projectionMatrix;
    matrix viewMatrix;
}

struct VertexInput
{
    float4 position : A;
};

struct VertexOutput
{
    float4 position : SV_POSITION;
};

VertexOutput main(VertexInput input)
{
    VertexOutput output;
    output.position = mul(projectionMatrix, mul(viewMatrix, input.position));
    return output;
}
