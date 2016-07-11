#version 430
#extension GL_ARB_separate_shader_objects : enable

#ifdef VULKAN
#define SLVM_GL_BINDING_VK_SET_BINDING(glb, s, b) set = s, binding = b
#define SLVM_VK_UNIFORM_SAMPLER(lc, name) layout lc uniform sampler name;
#define SLVM_COMBINE_SAMPLER_WITH(sampler, texture, samplerType) samplerType(texture, sampler)
#define SLVM_TEXTURE(vulkanType, openglType) vulkanType
#else
#define SLVM_GL_BINDING_VK_SET_BINDING(glb, s, b) binding = glb
#define SLVM_VK_UNIFORM_SAMPLER(lc, name) /* Declaration removed */
#define SLVM_COMBINE_SAMPLER_WITH(sampler, texture, samplerType) texture
#define SLVM_TEXTURE(vulkanType, openglType) openglType
#endif

struct ColorRampEntry
{
	float edge;
	vec4 color;
};

layout ( location = 0 ) in vec4 FragmentInput_sve_position;
layout ( location = 1 ) in vec2 FragmentInput_sve_texcoord;
layout ( location = 2 ) in vec4 FragmentInput_sve_color;
layout (push_constant) uniform CurrentColorRamp_block CurrentColorRamp;
layout ( SLVM_GL_BINDING_VK_SET_BINDING(1, 0, 1), std430 ) buffer ColorRamps_bufferBlock
{
	ColorRampEntry entries[];
} ColorRamps;

layout ( location = 0 ) out vec4 FragmentOutput_sve_color;
vec4 evaluateColorRamp (float arg1)
{
	int a;
	int b;
	int lastResult;
	int m;
	int entryIndex;
	float prevEdge;
	float nextEdge;
	float mixFactor;
	bool landResult;
	bool lorResult;
	if ((CurrentColorRamp.colorRampSize == 0))
		return vec4(1.0, 1.0, 1.0, 1.0);
	a = 0;
	b = CurrentColorRamp.colorRampSize;
	lastResult = a;
	while ((a < b))
	{
		m = ((a + b) / 2);
		if ((ColorRamps.entries[(CurrentColorRamp.colorRampIndex + m)].edge <= arg1))
		{
			lastResult = m;
			a = (m + 1);
		}
		else
			b = m;
	}
	entryIndex = (CurrentColorRamp.colorRampIndex + lastResult);
	prevEdge = ColorRamps.entries[entryIndex].edge;
	landResult = false;
	if ((lastResult == 0))
		landResult = (arg1 <= prevEdge);
	lorResult = true;
	if (!(landResult))
		lorResult = (lastResult == (CurrentColorRamp.colorRampSize - 1));
	if (lorResult)
		return ColorRamps.entries[entryIndex].color;
	nextEdge = ColorRamps.entries[(entryIndex + 1)].edge;
	mixFactor = ((arg1 - prevEdge) / (nextEdge - prevEdge));
	return mix(ColorRamps.entries[entryIndex].color, ColorRamps.entries[(entryIndex + 1)].color, vec4(mixFactor, mixFactor, mixFactor, mixFactor));
}

void main ()
{
	float coord;
	vec2 point;
	vec2 start;
	vec2 end;
	vec2 delta;
	vec2 center;
	vec2 focalPoint;
	float radius;
	vec2 delta;
	vec2 focalDelta;
	float E;
	float r2;
	vec4 _g1;
	point = FragmentInput_sve_position.xy;
	if ((FragmentInput_sve_texcoord.x == 0.0))
	{
		start = FragmentInput_sve_color.xy;
		end = FragmentInput_sve_color.zw;
		delta = (end - start);
		coord = (dot(delta, (point - start)) / dot(delta, delta));
	}
	else
	{
		center = FragmentInput_sve_color.xy;
		focalPoint = FragmentInput_sve_color.zw;
		radius = FragmentInput_sve_texcoord.y;
		delta = (point - focalPoint);
		focalDelta = (center - focalPoint);
		E = ((delta.x * focalDelta.y) - (delta.y * focalDelta.x));
		r2 = (radius * radius);
		coord = ((dot(delta, focalDelta) + sqrt(((r2 * dot(delta, delta)) - (E * E)))) / (r2 - dot(focalDelta, focalDelta)));
	}
	_g1 = evaluateColorRamp(coord);
	FragmentOutput_sve_color = _g1;
}

