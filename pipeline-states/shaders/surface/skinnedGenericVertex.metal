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

struct PoseState_bufferBlock
{
	metal::float4x4 matrices[1];
};

struct _SLVM_ShaderStageInput
{
	metal::float3 location0[[attribute(0)]];
	metal::float2 location1[[attribute(1)]];
	metal::float4 location2[[attribute(2)]];
	metal::float3 location3[[attribute(3)]];
	metal::float4 location4[[attribute(4)]];
	metal::float4 location5[[attribute(5)]];
	metal::int4 location6[[attribute(6)]];
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
metal::float3 transformNormalToView (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState);
metal::float4 transformVector4ToView (metal::float4 arg1, device const ObjectState_block* ObjectState, device const CameraState_block* CameraState, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID);
metal::float4 transformPositionToView (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID);
metal::float4 transformPositionToWorld (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState);
metal::float3 transformVectorToWorld (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState);
metal::float4 currentObjectColor (device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState);
bool isCurrentObjectInvisible (device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID);
metal::float3 skinPosition (metal::float3 arg1, device const PoseState_bufferBlock* PoseState, thread metal::int4* SkinnedGenericVertexLayout_sve_boneIndices, thread metal::float4* SkinnedGenericVertexLayout_sve_boneWeights);
metal::float3 skinVector (metal::float3 arg1, thread metal::int4* SkinnedGenericVertexLayout_sve_boneIndices, device const PoseState_bufferBlock* PoseState, thread metal::float4* SkinnedGenericVertexLayout_sve_boneWeights);
vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const CameraState_block* CameraState [[buffer(3)]], device const InstanceObjectState_bufferBlock* InstanceObjectState [[buffer(1)]], device const PoseState_bufferBlock* PoseState [[buffer(2)]], unsigned int VertexStage_sve_instanceID [[instance_id]], device const ObjectState_block* ObjectState [[buffer(0)]]);
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

metal::float3 transformNormalToView (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState)
{
	metal::float4 _g1;
	_g1 = (((metal::float4(arg1, 0.0) * InstanceObjectState->instanceStates[VertexStage_sve_instanceID].inverseMatrix) * ObjectState->objectState.inverseMatrix) * CameraState->inverseViewMatrix);
	return _g1.xyz;
}

metal::float4 transformVector4ToView (metal::float4 arg1, device const ObjectState_block* ObjectState, device const CameraState_block* CameraState, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID)
{
	return (CameraState->viewMatrix * (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * arg1)));
}

metal::float4 transformPositionToView (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState, device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID)
{
	metal::float4 _g2;
	_g2 = transformVector4ToView(metal::float4(arg1, 1.0), ObjectState, CameraState, InstanceObjectState, VertexStage_sve_instanceID);
	return _g2;
}

metal::float4 transformPositionToWorld (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState)
{
	return (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * metal::float4(arg1, 1.0)));
}

metal::float3 transformVectorToWorld (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	metal::float4 _g3;
	_g3 = (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * metal::float4(arg1, 0.0)));
	return _g3.xyz;
}

metal::float4 currentObjectColor (device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	return (ObjectState->objectState.color * InstanceObjectState->instanceStates[VertexStage_sve_instanceID].color);
}

bool isCurrentObjectInvisible (device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID)
{
	bool _l_lorResult;
	_l_lorResult = true;
	if (!((ObjectState->objectState.visible == 0)))
		_l_lorResult = (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].visible == 0);
	return _l_lorResult;
}

metal::float3 skinPosition (metal::float3 arg1, device const PoseState_bufferBlock* PoseState, thread metal::int4* SkinnedGenericVertexLayout_sve_boneIndices, thread metal::float4* SkinnedGenericVertexLayout_sve_boneWeights)
{
	metal::float4 _l_position4;
	metal::float3 _l_result;
	metal::float4 _g4;
	float _g5;
	metal::float4 _g6;
	float _g7;
	metal::float4 _g8;
	float _g9;
	metal::float4 _g10;
	float _g11;
	_l_position4 = metal::float4(arg1, 1.0);
	_g4 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).x] * _l_position4);
	_g5 = (*SkinnedGenericVertexLayout_sve_boneWeights).x;
	_l_result = (_g4.xyz * metal::float3(_g5, _g5, _g5));
	_g6 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).y] * _l_position4);
	_g7 = (*SkinnedGenericVertexLayout_sve_boneWeights).y;
	_l_result = (_l_result + (_g6.xyz * metal::float3(_g7, _g7, _g7)));
	_g8 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).z] * _l_position4);
	_g9 = (*SkinnedGenericVertexLayout_sve_boneWeights).z;
	_l_result = (_l_result + (_g8.xyz * metal::float3(_g9, _g9, _g9)));
	_g10 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).w] * _l_position4);
	_g11 = (*SkinnedGenericVertexLayout_sve_boneWeights).w;
	_l_result = (_l_result + (_g10.xyz * metal::float3(_g11, _g11, _g11)));
	return _l_result;
}

metal::float3 skinVector (metal::float3 arg1, thread metal::int4* SkinnedGenericVertexLayout_sve_boneIndices, device const PoseState_bufferBlock* PoseState, thread metal::float4* SkinnedGenericVertexLayout_sve_boneWeights)
{
	metal::float4 _l_vector4;
	metal::float3 _l_result;
	metal::float4 _g12;
	float _g13;
	metal::float4 _g14;
	float _g15;
	metal::float4 _g16;
	float _g17;
	metal::float4 _g18;
	float _g19;
	_l_vector4 = metal::float4(arg1, 0.0);
	_g12 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).x] * _l_vector4);
	_g13 = (*SkinnedGenericVertexLayout_sve_boneWeights).x;
	_l_result = (_g12.xyz * metal::float3(_g13, _g13, _g13));
	_g14 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).y] * _l_vector4);
	_g15 = (*SkinnedGenericVertexLayout_sve_boneWeights).y;
	_l_result = (_l_result + (_g14.xyz * metal::float3(_g15, _g15, _g15)));
	_g16 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).z] * _l_vector4);
	_g17 = (*SkinnedGenericVertexLayout_sve_boneWeights).z;
	_l_result = (_l_result + (_g16.xyz * metal::float3(_g17, _g17, _g17)));
	_g18 = (PoseState->matrices[(*SkinnedGenericVertexLayout_sve_boneIndices).w] * _l_vector4);
	_g19 = (*SkinnedGenericVertexLayout_sve_boneWeights).w;
	_l_result = (_l_result + (_g18.xyz * metal::float3(_g19, _g19, _g19)));
	return _l_result;
}

vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const CameraState_block* CameraState [[buffer(3)]], device const InstanceObjectState_bufferBlock* InstanceObjectState [[buffer(1)]], device const PoseState_bufferBlock* PoseState [[buffer(2)]], unsigned int VertexStage_sve_instanceID [[instance_id]], device const ObjectState_block* ObjectState [[buffer(0)]])
{
	metal::float4 _l_position4;
	metal::float3 _g20;
	metal::float3 _g21;
	metal::float3 _g22;
	metal::float3 _g23;
	float _g24;
	metal::float3 _g25;
	metal::float4 _g26;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float3* VertexOutput_sve_normal = &_slvm_stageout.location3;
	thread metal::float3* VertexOutput_sve_bitangent = &_slvm_stageout.location5;
	thread metal::int4* SkinnedGenericVertexLayout_sve_boneIndices = &_slvm_stagein.location6;
	thread metal::float4* VertexStage_sve_screenPosition = &_slvm_stageout.position;
	thread metal::float4* VertexOutput_sve_color = &_slvm_stageout.location2;
	thread metal::float4* SkinnedGenericVertexLayout_sve_boneWeights = &_slvm_stagein.location5;
	thread metal::float3* SkinnedGenericVertexLayout_sve_normal = &_slvm_stagein.location3;
	thread metal::float3* SkinnedGenericVertexLayout_sve_position = &_slvm_stagein.location0;
	thread metal::float4* SkinnedGenericVertexLayout_sve_tangent4 = &_slvm_stagein.location4;
	thread metal::float3* VertexOutput_sve_position = &_slvm_stageout.location0;
	thread metal::float2* VertexOutput_sve_texcoord = &_slvm_stageout.location1;
	thread metal::float3* VertexOutput_sve_tangent = &_slvm_stageout.location4;
	thread metal::float4* SkinnedGenericVertexLayout_sve_color = &_slvm_stagein.location2;
	thread metal::float2* SkinnedGenericVertexLayout_sve_texcoord = &_slvm_stagein.location1;
	(*VertexOutput_sve_color) = (*SkinnedGenericVertexLayout_sve_color);
	(*VertexOutput_sve_texcoord) = (*SkinnedGenericVertexLayout_sve_texcoord);
	_g20 = skinVector((*SkinnedGenericVertexLayout_sve_tangent4).xyz, SkinnedGenericVertexLayout_sve_boneIndices, PoseState, SkinnedGenericVertexLayout_sve_boneWeights);
	_g21 = transformNormalToView(_g20, InstanceObjectState, CameraState, VertexStage_sve_instanceID, ObjectState);
	(*VertexOutput_sve_tangent) = _g21;
	_g22 = skinVector((*SkinnedGenericVertexLayout_sve_normal), SkinnedGenericVertexLayout_sve_boneIndices, PoseState, SkinnedGenericVertexLayout_sve_boneWeights);
	_g23 = transformNormalToView(_g22, InstanceObjectState, CameraState, VertexStage_sve_instanceID, ObjectState);
	(*VertexOutput_sve_normal) = _g23;
	_g24 = (*SkinnedGenericVertexLayout_sve_tangent4).w;
	(*VertexOutput_sve_bitangent) = (metal::cross((*VertexOutput_sve_normal), (*VertexOutput_sve_tangent)) * metal::float3(_g24, _g24, _g24));
	_g25 = skinPosition((*SkinnedGenericVertexLayout_sve_position), PoseState, SkinnedGenericVertexLayout_sve_boneIndices, SkinnedGenericVertexLayout_sve_boneWeights);
	_g26 = transformPositionToView(_g25, InstanceObjectState, CameraState, ObjectState, VertexStage_sve_instanceID);
	_l_position4 = _g26;
	(*VertexOutput_sve_position) = _l_position4.xyz;
	(*VertexStage_sve_screenPosition) = (CameraState->projectionMatrix * _l_position4);
	return _slvm_stageout;
}

