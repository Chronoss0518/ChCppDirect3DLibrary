#ifndef ChShader_PublicHeader_DT
#define ChShader_PublicHeader_DT

//#define __SHADER__をhlsl側で定義する//

#include"../ShaderPublicInclude.hlsli"

#ifndef SPRITE_DATA_REGISTERNO
#define SPRITE_DATA_REGISTERNO 0
#endif

#ifdef __SHADER__
cbuffer SpriteData : register(CHANGE_CBUFFER(SPRITE_DATA_REGISTERNO))
#else
struct ChS_SpriteData
#endif
{
    row_major float4x4 spriteMat;
    float4 baseColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
    float2 moveUV = float2(0.0f, 0.0f);
    float alphaTestValue = 0.1f;
    float spriteDataTmp; //パッキング規則のためのバッファ//
};

#ifdef __SHADER__

struct MTWStruct
{
	float4 pos;
	float2 uv;
};

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv)
{
	MTWStruct res;

	res.pos = _pos;

	res.pos = mul(res.pos, spriteMat);

	//テクスチャマップ上の位置情報//
	res.uv = _uv + moveUV;

	return res;
}

void AlphaTest(float _alpha)
{
	clip(_alpha - alphaTestValue);
}

#endif

#endif
