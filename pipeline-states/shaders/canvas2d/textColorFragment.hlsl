Texture2D fontTexture : register(t1);
SamplerState fontSampler : register(s1);

struct FragmentInput
{
    float2 texcoord : TEXCOORD;
    float4 color : COLOR;
};

float4 main(FragmentInput input) : SV_TARGET
{
    float fontSample = fontTexture.Sample(fontSampler, input.texcoord).r;
    return float4(input.color.rgb, input.color.a*fontSample);
}
