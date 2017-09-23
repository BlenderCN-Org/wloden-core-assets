#include <metal_stdlib>

struct _SLVM_ShaderStageInput
{
};

struct _SLVM_ShaderStageOutput
{
	metal::float2 location0[[user(L0)]];
	metal::float4 position[[position]];
};

vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], int VertexStage_sve_vertexID [[vertex_id]], unsigned int VertexStage_sve_instanceID [[instance_id]]);
vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], int VertexStage_sve_vertexID [[vertex_id]], unsigned int VertexStage_sve_instanceID [[instance_id]])
{
	int _l_cellIndex;
	int _l_cellExtraOffset;
	int _l_column;
	int _l_row;
	int _l_dx;
	int _l_dy;
	float _l_x;
	float _l_y;
	metal::float2 _l_pos;
	metal::float2 _l_texcoord;
	float _l_r;
	float _l_r2;
	bool _l_lorResult;
	bool _g1;
	int _l_g26;
	bool _g2;
	bool _g3;
	int _l_g41;
	float _g4;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float2* VertexOutput_sve_texcoord = &_slvm_stageout.location0;
	thread metal::float4* VertexStage_sve_screenPosition = &_slvm_stageout.position;
	_l_cellIndex = (VertexStage_sve_vertexID / 6);
	_l_cellExtraOffset = (VertexStage_sve_vertexID % 6);
	_l_column = (_l_cellIndex % 16);
	_l_row = (_l_cellIndex / 16);
	_l_lorResult = true;
	if (!((_l_cellExtraOffset == 1)))
		_l_lorResult = (_l_cellExtraOffset == 2);
	_g1 = true;
	if (!(_l_lorResult))
		_g1 = (_l_cellExtraOffset == 5);
	if (_g1)
		_l_g26 = 1;
	else
		_l_g26 = 0;
	_l_dx = _l_g26;
	_g2 = true;
	if (!((_l_cellExtraOffset == 2)))
		_g2 = (_l_cellExtraOffset == 3);
	_g3 = true;
	if (!(_g2))
		_g3 = (_l_cellExtraOffset == 5);
	if (_g3)
		_l_g41 = 1;
	else
		_l_g41 = 0;
	_l_dy = _l_g41;
	_l_x = (((float) (_l_column + _l_dx)) / 16.0);
	_l_y = (((float) (_l_row + _l_dy)) / 16.0);
	_l_pos = ((metal::float2(_l_x, _l_y) * metal::float2(2.0, 2.0)) - metal::float2(1.0, 1.0));
	_l_texcoord = ((_l_pos * metal::float2(0.5, 0.5)) + metal::float2(0.5, 0.5));
	_l_pos = (_l_pos * metal::float2(0.5, 1.0));
	_l_r = metal::length(_l_pos);
	_l_r2 = (_l_r * _l_r);
	_g4 = ((1.0 + (0.22 * _l_r2)) + ((0.24 * _l_r2) * _l_r2));
	_l_pos = (_l_pos / metal::float2(_g4, _g4));
	_l_texcoord = metal::float2(((_l_texcoord.x * 0.5) + (((float) VertexStage_sve_instanceID) * 0.5)), _l_texcoord.y);
	_l_pos = metal::float2(((_l_pos.x - 0.5) + (((float) VertexStage_sve_instanceID) * 1.0)), _l_pos.y);
	(*VertexOutput_sve_texcoord) = _l_texcoord;
	(*VertexStage_sve_screenPosition) = metal::float4(_l_pos, 0.0, 1.0);
	return _slvm_stageout;
}

