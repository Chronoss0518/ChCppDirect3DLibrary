#ifndef ChShader_PublicHeader_DP
#define ChShader_PublicHeader_DP

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"
#include"DrawPolygonBase.hlsli"

#ifdef __SHADER__

#ifndef _SM5_0_

MTWStruct ModelToWorld(
	ChDrawData _drawData,
	ChModelData _modelData,
	ChFrameData _frameData,
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix)
{
	return ModelToWorldBase(_drawData,_modelData,_frameData,_pos,_uv,_normal,_faceNormal,_frameMatrix);
}

void AlphaTest(ChDrawData _data,float _alpha)
{
	AlphaTestBase(_data,_alpha);
}

#else

cbuffer DrawData :register(CHANGE_CBUFFER(CH_DP_DRAW_DATA_REGISTERNO))
{
	ChDrawData drawData;
};

cbuffer ModelData :register(CHANGE_CBUFFER(CH_DP_MODEL_DATA_REGISTERNO))
{
	ChModelData modelData;
};

cbuffer FrameData :register(CHANGE_CBUFFER(CH_DP_FRAME_DATA_REGISTERNO))
{
	ChFrameData frameData;
};

cbuffer Material:register(CHANGE_CBUFFER(CH_DP_MATERIAL_DATA_REGISTERNO))
{
	ChMaterial mate;
};

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix)
{
	return ModelToWorldBase(drawData,modelData,frameData,_pos,_uv,_normal,_faceNormal,_frameMatrix);
}

void AlphaTest(float _alpha)
{
	AlphaTestBase(drawData,_alpha);
}

#endif

#endif

#endif