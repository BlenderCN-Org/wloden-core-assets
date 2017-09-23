#include <metal_stdlib>

struct _SLVM_ShaderStageInput
{
};

struct _SLVM_ShaderStageOutput
{
	metal::float2 location0[[user(L0)]];
	metal::float4 position[[position]];
};

vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], int VertexStage_sve_vertexID [[vertex_id]]);
vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], int VertexStage_sve_vertexID [[vertex_id]])
{
	metal::float2 _l_position;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float2* VertexOutput_sve_texcoord = &_slvm_stageout.location0;
	thread metal::float4* VertexStage_sve_screenPosition = &_slvm_stageout.position;
	_l_position = metal::float2(0.0, 0.0);
	if (VertexStage_sve_vertexID == 0)
		_l_position = metal::float2(-1.0, 1.0);
	else
	{
		if (VertexStage_sve_vertexID == 1)
			_l_position = metal::float2(1.0, 1.0);
		else
		{
			if (VertexStage_sve_vertexID == 2)
				_l_position = metal::float2(-1.0, -1.0);
			else
			{
				if (VertexStage_sve_vertexID == 3)
					_l_position = metal::float2(1.0, -1.0);
			}
		}
	}
	(*VertexOutput_sve_texcoord) = ((_l_position * metal::float2(0.5, 0.5)) + metal::float2(0.5, 0.5));
	(*VertexStage_sve_screenPosition) = metal::float4(_l_position, 0.0, 1.0);
	return _slvm_stageout;
}

