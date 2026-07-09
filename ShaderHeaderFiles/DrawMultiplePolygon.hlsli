#ifndef ChShader_PublicHeader_DMP
#define ChShader_PublicHeader_DMP

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"
#include"DrawPolygonBase.hlsli"

#ifndef CH_DMP_MAX_FRAME_COUNT 
#define CH_DMP_MAX_FRAME_COUNT 128
#endif

struct ChFrameDatas
{
    ChFrameData datas[CH_DMP_MAX_FRAME_COUNT];
    int drawFlgs[CH_DMP_MAX_FRAME_COUNT];
};

struct ChMaterialDatas
{
    ChMaterialData datas[CH_DMP_MAX_FRAME_COUNT];
};

#ifdef __SHADER__

#ifdef _SM5_0_

cbuffer DrawData :register(CH_CHANGE_CBUFFER(CH_DP_DRAW_DATA_REGISTERNO))
{
	ChDrawData drawData;
};

cbuffer ModelData :register(CH_CHANGE_CBUFFER(CH_DP_MODEL_DATA_REGISTERNO))
{
	ChModelData modelData;
};

cbuffer FrameData :register(CH_CHANGE_CBUFFER(CH_DP_FRAME_DATA_REGISTERNO))
{
	ChFrameDatas frameDatas;
};

cbuffer Material:register(CH_CHANGE_CBUFFER(CH_DP_MATERIAL_DATA_REGISTERNO))
{
	ChMaterialDatas mateDatas;
};

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix,
	int _no)
{
	if(_no >= CH_DMP_MAX_FRAME_COUNT || _no < 0)_no = 0;
	return ModelToWorldBase(
		drawData,
		modelData,
		frameDatas.datas[_no],
		mateDatas.datas[_no],
		_pos,
		_uv,
		_normal,
		_faceNormal,
		_frameMatrix);
}

void AlphaTest(float _alpha)
{
	AlphaTestBase(drawData,_alpha);
}

bool IsDrawFlags(uint _num)
{
	return frameDatas.drawFlgs[_num] != 0;
}

float GetMod(float _val,float _min,float _max)
{
	if(_max <= _min)return _val;

	float res = _val;
	
	float size = _max - _min;

	while(res > _max)
	{
		res -= size;
	}

	while(res < _min)
	{
		res += size;
	}

	return res;
}

float2 GetUV(float2 _uv,uint _no)
{	
	if(_no >= CH_DMP_MAX_FRAME_COUNT)_no = 0;
	float paddingBase = _no/(float)CH_DMP_MAX_FRAME_COUNT;
	float paddingMax = (_no + 1)/(float)CH_DMP_MAX_FRAME_COUNT;
	float paddingSize = 1.0f/CH_DMP_MAX_FRAME_COUNT;

	
	float2 res = _uv;
	res.y = GetMod(res.y,0.0f,1.0f);
	res.x = GetMod(res.x,0.0f,1.0f);
	
	//res.y = min(max(paddingBase + paddingSize * res.y,paddingMax),paddingBase);
	res.x= min(max(paddingBase + paddingSize * res.x,paddingMax),paddingBase);

	return res;
}

#endif

#endif

#endif