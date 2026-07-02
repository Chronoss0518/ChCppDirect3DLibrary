#ifndef ChShader_PublicHeader_DMP
#define ChShader_PublicHeader_DMP

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

#ifndef MAX_FRAME_COUNT 
#define MAX_FRAME_COUNT 32
#endif

struct ChCharaDatas
{
    ChCharaData datas[MAX_FRAME_COUNT];
};

struct ChMaterials
{
    ChMaterial datas[MAX_FRAME_COUNT];
};

#ifdef __SHADER__

#ifdef _SM5_0_

cbuffer DrawData :register(CHANGE_CBUFFER(DRAW_DATA_REGISTERNO))
{
	ChDrawData drawData;
};

cbuffer CharaData :register(CHANGE_CBUFFER(CHARACTOR_DATA_REGISTERNO))
{
	ChCharaDatas charaDatas;
};

cbuffer Material:register(CHANGE_CBUFFER(MATERIAL_DATA_REGISTERNO))
{
	ChMaterials mates;
};

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix,
	int _no)
{
	if(_no >= MAX_FRAME_COUNT || _no < 0)_no = 0;
	return ModelToWorldBase(drawData,charaDatas.datas[_no],_pos,_uv,_normal,_faceNormal,_frameMatrix);
}

void AlphaTest(float _alpha)
{
	AlphaTestBase(drawData,_alpha);
}

#endif

#endif

#endif