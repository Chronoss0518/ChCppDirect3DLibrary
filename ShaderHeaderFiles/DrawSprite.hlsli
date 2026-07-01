#ifndef ChShader_PublicHeader_DT
#define ChShader_PublicHeader_DT

//#define __SHADER__をhlsl側で定義する//

#include"ShaderPublicInclude.hlsli"

#ifndef SPRITE_DATA_REGISTERNO
#define SPRITE_DATA_REGISTERNO 0
#endif

struct ChSpriteData
{
    row_major float4x4 spriteMat;
	
    float4 baseColor
#ifdef __cplusplus
	= float4(1.0f, 1.0f, 1.0f, 1.0f)
#endif
	;
    float2 moveUV
#ifdef __cplusplus
	= float2(0.0f, 0.0f)
#endif
	;
    float alphaTestValue
#ifdef __cplusplus
	= 0.1f
#endif
	;
    float nonData; //パッキング規則のためのバッファ//
};

#ifdef __SHADER__

struct MTWStruct
{
	float4 pos;
	float2 uv;
};

MTWStruct ModelToWorldBase(
	ChSpriteData _data,
	float4 _pos,
	float2 _uv);

#ifndef _SM5_0_

MTWStruct ModelToWorld(
	ChSpriteData _data,
	float4 _pos,
	float2 _uv)
{
	return ModelToWorldBase(_data,_pos,_uv);
}

void AlphaTest(ChSpriteData _data,float _alpha)
{
	clip(_alpha - _data.alphaTestValue);
}

#else

cbuffer SpriteData : register(CHANGE_CBUFFER(SPRITE_DATA_REGISTERNO))
{
	ChSpriteData spriteData;
};

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv)
{
	return ModelToWorldBase(spriteData,_pos,_uv);
}

void AlphaTest(float _alpha)
{
	clip(_alpha - spriteData.alphaTestValue);
}

#endif

MTWStruct ModelToWorldBase(
	ChSpriteData _data,
	float4 _pos,
	float2 _uv)
{
	MTWStruct res;

	res.pos = _pos;

	res.pos = mul(res.pos, _data.spriteMat);

	//テクスチャマップ上の位置情報//
	res.uv = _uv + _data.moveUV;

	return res;
}

#endif

#endif
