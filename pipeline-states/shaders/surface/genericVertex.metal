#include <metal_stdlib>

struct ObjectStateData
{
	metal::float4x4 matrix;
	metal::float4x4 inverseMatrix;
	metal::float4 color;
	int visible;
};

struct ObjectState_block
{
	ObjectStateData objectState;
};

struct CameraState_block
{
	metal::float4x4 inverseViewMatrix;
	metal::float4x4 viewMatrix;
	metal::float4x4 projectionMatrix;
	float currentTime;
};

struct LightSource
{
	metal::float4 position;
	metal::float4 intensity;
	metal::float3 spotDirection;
	float innerCosCutoff;
	float outerCosCutoff;
	float spotExponent;
	float radius;
};

struct GlobalLightingState_block
{
	metal::float4 groundLighting;
	metal::float4 skyLighting;
	metal::float3 sunDirection;
	int numberOfLights;
	LightSource lightSources[16];
};

struct InstanceObjectState_bufferBlock
{
	ObjectStateData instanceStates[1];
};

struct _SLVM_ShaderStageInput
{
	metal::float3 location0[[attribute(0)]];
	metal::float2 location1[[attribute(1)]];
	metal::float4 location2[[attribute(2)]];
	metal::float3 location3[[attribute(3)]];
	metal::float4 location4[[attribute(4)]];
};

struct _SLVM_ShaderStageOutput
{
	metal::float4 position[[position]];
	metal::float3 location0[[user(L0)]];
	metal::float2 location1[[user(L1)]];
	metal::float4 location2[[user(L2)]];
	metal::float3 location3[[user(L3)]];
	metal::float3 location4[[user(L4)]];
	metal::float3 location5[[user(L5)]];
};

metal::float3 cameraWorldPosition (device const CameraState_block* CameraState);
metal::float3 fresnelSchlick (metal::float3 arg1, float arg2);
float fresnelSchlick (float arg1, float arg2);
metal::float3 transformNormalToView (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState, device const ObjectState_block* ObjectState);
metal::float4 transformVector4ToView (metal::float4 arg1, device const CameraState_block* CameraState, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID);
metal::float4 transformPositionToView (metal::float3 arg1, device const ObjectState_block* ObjectState, device const CameraState_block* CameraState, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID);
metal::float4 transformPositionToWorld (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID);
metal::float3 transformVectorToWorld (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID);
metal::float4 currentObjectColor (device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState);
bool isCurrentObjectInvisible (unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState);
vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const ObjectState_block* ObjectState [[buffer(1)]], device const InstanceObjectState_bufferBlock* InstanceObjectState [[buffer(2)]], unsigned int VertexStage_sve_instanceID [[instance_id]], device const CameraState_block* CameraState [[buffer(4)]]);
metal::float3 cameraWorldPosition (device const CameraState_block* CameraState)
{
	return CameraState->inverseViewMatrix[3].xyz;
}

metal::float3 fresnelSchlick (metal::float3 arg1, float arg2)
{
	float _l_powFactor;
	float _l_powFactor2;
	float _l_powFactor4;
	float _l_powValue;
	_l_powFactor = (1.0 - arg2);
	_l_powFactor2 = (_l_powFactor * _l_powFactor);
	_l_powFactor4 = (_l_powFactor2 * _l_powFactor2);
	_l_powValue = (_l_powFactor4 * _l_powFactor);
	return (arg1 + ((metal::float3(1.0, 1.0, 1.0) - arg1) * metal::float3(_l_powValue, _l_powValue, _l_powValue)));
}

float fresnelSchlick (float arg1, float arg2)
{
	float _l_powFactor;
	float _l_powFactor2;
	float _l_powFactor4;
	float _l_powValue;
	_l_powFactor = (1.0 - arg2);
	_l_powFactor2 = (_l_powFactor * _l_powFactor);
	_l_powFactor4 = (_l_powFactor2 * _l_powFactor2);
	_l_powValue = (_l_powFactor4 * _l_powFactor);
	return (arg1 + ((1.0 - arg1) * _l_powValue));
}

metal::float3 transformNormalToView (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState, device const ObjectState_block* ObjectState)
{
	metal::float4 _g1;
	_g1 = (((metal::float4(arg1, 0.0) * InstanceObjectState->instanceStates[VertexStage_sve_instanceID].inverseMatrix) * ObjectState->objectState.inverseMatrix) * CameraState->inverseViewMatrix);
	return _g1.xyz;
}

metal::float4 transformVector4ToView (metal::float4 arg1, device const CameraState_block* CameraState, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID)
{
	return (CameraState->viewMatrix * (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * arg1)));
}

metal::float4 transformPositionToView (metal::float3 arg1, device const ObjectState_block* ObjectState, device const CameraState_block* CameraState, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID)
{
	metal::float4 _g2;
	_g2 = transformVector4ToView(metal::float4(arg1, 1.0), CameraState, InstanceObjectState, ObjectState, VertexStage_sve_instanceID);
	return _g2;
}

metal::float4 transformPositionToWorld (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID)
{
	return (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * metal::float4(arg1, 1.0)));
}

metal::float3 transformVectorToWorld (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID)
{
	metal::float4 _g3;
	_g3 = (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * metal::float4(arg1, 0.0)));
	return _g3.xyz;
}

metal::float4 currentObjectColor (device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	return (ObjectState->objectState.color * InstanceObjectState->instanceStates[VertexStage_sve_instanceID].color);
}

bool isCurrentObjectInvisible (unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState)
{
	bool _l_lorResult;
	_l_lorResult = true;
	if (!((ObjectState->objectState.visible == 0)))
		_l_lorResult = (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].visible == 0);
	return _l_lorResult;
}

vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const ObjectState_block* ObjectState [[buffer(1)]], device const InstanceObjectState_bufferBlock* InstanceObjectState [[buffer(2)]], unsigned int VertexStage_sve_instanceID [[instance_id]], device const CameraState_block* CameraState [[buffer(4)]])
{
	metal::float4 _l_position4;
	bool _g4;
	metal::float4 _g5;
	metal::float3 _g6;
	metal::float3 _g7;
	float _g8;
	metal::float4 _g9;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float2* GenericVertexLayout_sve_texcoord = &_slvm_stagein.location1;
	thread metal::float4* VertexStage_sve_screenPosition = &_slvm_stageout.position;
	thread metal::float3* VertexOutput_sve_position = &_slvm_stageout.location0;
	thread metal::float3* VertexOutput_sve_bitangent = &_slvm_stageout.location5;
	thread metal::float3* GenericVertexLayout_sve_normal = &_slvm_stagein.location3;
	thread metal::float4* GenericVertexLayout_sve_color = &_slvm_stagein.location2;
	thread metal::float3* VertexOutput_sve_tangent = &_slvm_stageout.location4;
	thread metal::float2* VertexOutput_sve_texcoord = &_slvm_stageout.location1;
	thread metal::float4* GenericVertexLayout_sve_tangent4 = &_slvm_stagein.location4;
	thread metal::float4* VertexOutput_sve_color = &_slvm_stageout.location2;
	thread metal::float3* VertexOutput_sve_normal = &_slvm_stageout.location3;
	thread metal::float3* GenericVertexLayout_sve_position = &_slvm_stagein.location0;
	_g4 = isCurrentObjectInvisible(VertexStage_sve_instanceID, InstanceObjectState, ObjectState);
	if (_g4)
	{
		(*VertexStage_sve_screenPosition) = metal::float4(2.0, 2.0, 2.0, 1.0);
		return _slvm_stageout;
	}
	_g5 = currentObjectColor(ObjectState, VertexStage_sve_instanceID, InstanceObjectState);
	(*VertexOutput_sve_color) = ((*GenericVertexLayout_sve_color) * _g5);
	(*VertexOutput_sve_texcoord) = (*GenericVertexLayout_sve_texcoord);
	_g6 = transformNormalToView((*GenericVertexLayout_sve_tangent4).xyz, VertexStage_sve_instanceID, InstanceObjectState, CameraState, ObjectState);
	(*VertexOutput_sve_tangent) = _g6;
	_g7 = transformNormalToView((*GenericVertexLayout_sve_normal), VertexStage_sve_instanceID, InstanceObjectState, CameraState, ObjectState);
	(*VertexOutput_sve_normal) = _g7;
	_g8 = (*GenericVertexLayout_sve_tangent4).w;
	(*VertexOutput_sve_bitangent) = (metal::cross((*VertexOutput_sve_normal), (*VertexOutput_sve_tangent)) * metal::float3(_g8, _g8, _g8));
	_g9 = transformPositionToView((*GenericVertexLayout_sve_position), ObjectState, CameraState, InstanceObjectState, VertexStage_sve_instanceID);
	_l_position4 = _g9;
	(*VertexOutput_sve_position) = _l_position4.xyz;
	(*VertexStage_sve_screenPosition) = (CameraState->projectionMatrix * _l_position4);
	return _slvm_stageout;
}

