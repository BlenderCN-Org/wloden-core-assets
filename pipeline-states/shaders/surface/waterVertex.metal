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

struct WaterHarmonic
{
	metal::float2 centerOrDirection;
	float amplitude;
	float frequency;
	int isRadial;
};

struct MaterialState_block
{
	metal::float4 albedo;
	metal::float3 fresnel;
	float smoothness;
	float propagationSpeed;
	WaterHarmonic harmonics[5];
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
	metal::float3 location0[[user(L0)]];
	metal::float2 location1[[user(L1)]];
	metal::float4 location2[[user(L2)]];
	metal::float3 location3[[user(L3)]];
	metal::float3 location4[[user(L4)]];
	metal::float3 location5[[user(L5)]];
	metal::float4 position[[position]];
};

metal::float3 cameraWorldPosition (device const CameraState_block* CameraState);
metal::float3 fresnelSchlick (metal::float3 arg1, float arg2);
float fresnelSchlick (float arg1, float arg2);
metal::float3 transformNormalToView (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID, device const CameraState_block* CameraState, device const ObjectState_block* ObjectState);
metal::float4 transformVector4ToView (metal::float4 arg1, device const CameraState_block* CameraState, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState);
metal::float4 transformPositionToView (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState);
metal::float4 transformPositionToWorld (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState);
metal::float3 transformVectorToWorld (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState);
metal::float4 currentObjectColor (unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState);
bool isCurrentObjectInvisible (device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState);
vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const InstanceObjectState_bufferBlock* InstanceObjectState [[buffer(2)]], device const ObjectState_block* ObjectState [[buffer(1)]], device const MaterialState_block* MaterialState , unsigned int VertexStage_sve_instanceID [[instance_id]], device const CameraState_block* CameraState [[buffer(4)]]);
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

metal::float3 transformNormalToView (metal::float3 arg1, device const InstanceObjectState_bufferBlock* InstanceObjectState, unsigned int VertexStage_sve_instanceID, device const CameraState_block* CameraState, device const ObjectState_block* ObjectState)
{
	metal::float4 _g1;
	_g1 = (((metal::float4(arg1, 0.0) * InstanceObjectState->instanceStates[VertexStage_sve_instanceID].inverseMatrix) * ObjectState->objectState.inverseMatrix) * CameraState->inverseViewMatrix);
	return _g1.xyz;
}

metal::float4 transformVector4ToView (metal::float4 arg1, device const CameraState_block* CameraState, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	return (CameraState->viewMatrix * (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * arg1)));
}

metal::float4 transformPositionToView (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const CameraState_block* CameraState)
{
	metal::float4 _g2;
	_g2 = transformVector4ToView(metal::float4(arg1, 1.0), CameraState, VertexStage_sve_instanceID, ObjectState, InstanceObjectState);
	return _g2;
}

metal::float4 transformPositionToWorld (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState, device const ObjectState_block* ObjectState)
{
	return (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * metal::float4(arg1, 1.0)));
}

metal::float3 transformVectorToWorld (metal::float3 arg1, unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	metal::float4 _g3;
	_g3 = (ObjectState->objectState.matrix * (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].matrix * metal::float4(arg1, 0.0)));
	return _g3.xyz;
}

metal::float4 currentObjectColor (unsigned int VertexStage_sve_instanceID, device const ObjectState_block* ObjectState, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	return (ObjectState->objectState.color * InstanceObjectState->instanceStates[VertexStage_sve_instanceID].color);
}

bool isCurrentObjectInvisible (device const ObjectState_block* ObjectState, unsigned int VertexStage_sve_instanceID, device const InstanceObjectState_bufferBlock* InstanceObjectState)
{
	bool _l_lorResult;
	_l_lorResult = true;
	if (!((ObjectState->objectState.visible == 0)))
		_l_lorResult = (InstanceObjectState->instanceStates[VertexStage_sve_instanceID].visible == 0);
	return _l_lorResult;
}

vertex _SLVM_ShaderStageOutput shaderMain (_SLVM_ShaderStageInput _slvm_stagein [[stage_in]], device const InstanceObjectState_bufferBlock* InstanceObjectState [[buffer(2)]], device const ObjectState_block* ObjectState [[buffer(1)]], device const MaterialState_block* MaterialState , unsigned int VertexStage_sve_instanceID [[instance_id]], device const CameraState_block* CameraState [[buffer(4)]])
{
	float _l_height;
	metal::float3 _l_position;
	metal::float2 _l_tangentialContributions;
	int _l_i;
	WaterHarmonic _l_harmonic;
	float _l_distance;
	metal::float2 _l_distanceDerivatives;
	float _l_omega;
	float _l_kappa;
	float _l_phase;
	metal::float3 _l_tangent;
	metal::float3 _l_bitangent;
	metal::float3 _l_normal;
	metal::float4 _l_position4;
	float _g4;
	metal::float3 _g5;
	metal::float3 _g6;
	metal::float3 _g7;
	metal::float4 _g8;
	_SLVM_ShaderStageOutput _slvm_stageout;
	thread metal::float3* VertexOutput_sve_tangent = &_slvm_stageout.location4;
	thread metal::float2* VertexOutput_sve_texcoord = &_slvm_stageout.location1;
	thread metal::float3* VertexOutput_sve_bitangent = &_slvm_stageout.location5;
	thread metal::float4* GenericVertexLayout_sve_color = &_slvm_stagein.location2;
	thread metal::float2* GenericVertexLayout_sve_texcoord = &_slvm_stagein.location1;
	thread metal::float3* GenericVertexLayout_sve_position = &_slvm_stagein.location0;
	thread metal::float3* VertexOutput_sve_normal = &_slvm_stageout.location3;
	thread metal::float3* VertexOutput_sve_position = &_slvm_stageout.location0;
	thread metal::float4* VertexOutput_sve_color = &_slvm_stageout.location2;
	thread metal::float4* VertexStage_sve_screenPosition = &_slvm_stageout.position;
	_l_height = 0.0;
	_l_position = (*GenericVertexLayout_sve_position);
	_l_tangentialContributions = metal::float2(0.0, 0.0);
	_l_i = 0;
	for (;(_l_i < 5); _l_i = (_l_i + 1))
	{
		_l_harmonic = MaterialState->harmonics[_l_i];
		if (_l_harmonic.isRadial == 1)
		{
			_l_distance = metal::length((_l_position.xz - _l_harmonic.centerOrDirection));
			_l_distanceDerivatives = ((_l_position.xz - _l_harmonic.centerOrDirection) / metal::float2(_l_distance, _l_distance));
		}
		else
		{
			_l_distance = metal::dot(_l_position.xz, _l_harmonic.centerOrDirection);
			_l_distanceDerivatives = _l_harmonic.centerOrDirection;
		}
		_l_omega = (6.283185307179586 * _l_harmonic.frequency);
		_l_kappa = (_l_omega / MaterialState->propagationSpeed);
		_l_phase = ((_l_kappa * _l_distance) + (_l_omega * CameraState->currentTime));
		_l_height = (_l_height + (_l_harmonic.amplitude * metal::sin(_l_phase)));
		_g4 = ((_l_harmonic.amplitude * _l_kappa) * metal::cos(_l_phase));
		_l_tangentialContributions = (_l_tangentialContributions + (metal::float2(_g4, _g4) * _l_distanceDerivatives));
	}
	_l_position = (_l_position + metal::float3(0.0, _l_height, 0.0));
	_l_tangent = metal::normalize(metal::float3(1.0, _l_tangentialContributions.x, 0.0));
	_l_bitangent = metal::normalize(metal::float3(0.0, _l_tangentialContributions.y, 1.0));
	_l_normal = metal::normalize(metal::cross(_l_bitangent, _l_tangent));
	(*VertexOutput_sve_color) = (*GenericVertexLayout_sve_color);
	(*VertexOutput_sve_texcoord) = (*GenericVertexLayout_sve_texcoord);
	_g5 = transformNormalToView(_l_tangent, InstanceObjectState, VertexStage_sve_instanceID, CameraState, ObjectState);
	(*VertexOutput_sve_tangent) = _g5;
	_g6 = transformNormalToView(_l_bitangent, InstanceObjectState, VertexStage_sve_instanceID, CameraState, ObjectState);
	(*VertexOutput_sve_bitangent) = _g6;
	_g7 = transformNormalToView(_l_normal, InstanceObjectState, VertexStage_sve_instanceID, CameraState, ObjectState);
	(*VertexOutput_sve_normal) = _g7;
	_g8 = transformPositionToView(_l_position, VertexStage_sve_instanceID, ObjectState, InstanceObjectState, CameraState);
	_l_position4 = _g8;
	(*VertexOutput_sve_position) = _l_position4.xyz;
	(*VertexStage_sve_screenPosition) = (CameraState->projectionMatrix * _l_position4);
	return _slvm_stageout;
}

