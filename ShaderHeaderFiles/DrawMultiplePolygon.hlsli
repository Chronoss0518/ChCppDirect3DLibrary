#ifndef ChShader_PublicHeader_DMP
#define ChShader_PublicHeader_DMP

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"
#include"DrawPolygonBase.hlsli"

#ifndef CH_DMP_MAX_FRAME_COUNT 
#define CH_DMP_MAX_FRAME_COUNT 32
#endif

struct ChFrameDatas
{
    ChFrameData datas[CH_DMP_MAX_FRAME_COUNT];
    int drawFlgs[CH_DMP_MAX_FRAME_COUNT];
};

struct ChMaterials
{
    ChMaterial datas[CH_DMP_MAX_FRAME_COUNT];
};

#ifdef __SHADER__

#ifdef _SM5_0_

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
	ChFrameDatas frameDatas;
};

cbuffer Material:register(CHANGE_CBUFFER(CH_DP_MATERIAL_DATA_REGISTERNO))
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
	return ModelToWorldBase(drawData,modelData,charaDatas.datas[_no],_pos,_uv,_normal,_faceNormal,_frameMatrix);
}

void AlphaTest(float _alpha)
{
	AlphaTestBase(drawData,_alpha);
}

#endif

#endif

#endif