#ifndef ChShader_PublicHeader_DP
#define ChShader_PublicHeader_DP

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"
#include"DrawPolygonBase.hlsli"

#ifndef DRAW_DATA_REGISTERNO
#define DRAW_DATA_REGISTERNO 0
#endif

#ifndef CHARACTOR_DATA_REGISTERNO
#define CHARACTOR_DATA_REGISTERNO 1
#endif

#ifndef MATERIAL_DATA_REGISTERNO 
#define MATERIAL_DATA_REGISTERNO 2
#endif

#ifdef __SHADER__

#ifndef _SM5_0_

MTWStruct ModelToWorld(
	ChDrawData _drawData,
	ChCharaData _charaData,
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix)
{
	return ModelToWorldBase(_drawData,_charaData,_pos,_uv,_normal,_faceNormal,_frameMatrix);
}

void AlphaTest(ChDrawData _data,float _alpha)
{
	AlphaTestBase(_data,_alpha);
}

#else

cbuffer DrawData :register(CHANGE_CBUFFER(DRAW_DATA_REGISTERNO))
{
	ChDrawData drawData;
};

cbuffer CharaData :register(CHANGE_CBUFFER(CHARACTOR_DATA_REGISTERNO))
{
	ChCharaData charaDatas;
};

cbuffer Material:register(CHANGE_CBUFFER(MATERIAL_DATA_REGISTERNO))
{
	uniform ChMaterial mate;
};

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix)
{
	return ModelToWorldBase(drawData,charaDatas,_pos,_uv,_normal,_faceNormal,_frameMatrix);
}

void AlphaTest(float _alpha)
{
	AlphaTestBase(drawData,_alpha);
}

#endif

#endif

#endif