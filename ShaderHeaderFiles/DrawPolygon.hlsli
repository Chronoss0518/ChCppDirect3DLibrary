#ifndef ChShader_PublicHeader_DP
#define ChShader_PublicHeader_DP

//#define __SHADER__をhlsl側で定義する//

#include"ShaderPublicInclude.hlsli"

#ifndef DRAW_DATA_REGISTERNO
#define DRAW_DATA_REGISTERNO 0
#endif

#ifndef CHARACTOR_DATA_REGISTERNO
#define CHARACTOR_DATA_REGISTERNO 1
#endif

#ifndef CHARACTOR_DATA_ARRAY_COUNT
#define CHARACTOR_DATA_ARRAY_COUNT 32
#endif

#ifndef MATERIAL_DATA_REGISTERNO 
#define MATERIAL_DATA_REGISTERNO 2
#endif

#ifndef NORMAL_TEXTURE_REGISTER
#define	NORMAL_TEXTURE_REGISTER 1
#endif

struct ChP_DrawData
{
	row_major float4x4 viewMat;

	row_major float4x4 proMat;
};

struct ChP_CharaData
{
	row_major float4x4 worldMat;

	row_major float4x4 frameMatrix;
	
    float2 moveUV;
	
    float alphaTestValue;
	
    float charaDataTmp;
};

struct ChP_Material
{
	//diffuse//
    float4 dif;
	//specular//
    float3 speCol;
    float spePow;
	//ambient//
    float4 ambient;
};

#ifdef __SHADER__

cbuffer DrawData :register(CHANGE_CBUFFER(DRAW_DATA_REGISTERNO))
{
	ChP_DrawData drawData;
};

cbuffer CharaData :register(CHANGE_CBUFFER(CHARACTOR_DATA_REGISTERNO))
{
	ChP_CharaData charaDatas;
};

cbuffer Material:register(CHANGE_CBUFFER(MATERIAL_DATA_REGISTERNO))
{
	uniform ChP_Material mate;
};

texture2D normalTex :register(CHANGE_TBUFFER(NORMAL_TEXTURE_REGISTER));
//画像から1ピクセルの色を取得するための物//
sampler normalSmp :register(CHANGE_SBUFFER(NORMAL_TEXTURE_REGISTER));

struct MTWStruct
{
	float3 vertexNormal;
	float3 faceNormal;
	float4 worldPos;
	float4 viewPos;
	float4 proPos;
	float2 uv;
};

float4x4 GetInitMatrix4x4()
{
	return float4x4(
		1.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 1.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f);
}

float3x3 GetInitMatrix3x3()
{
	return float3x3(
		1.0f, 0.0f, 0.0f,
		0.0f, 1.0f, 0.0f, 
		0.0f, 0.0f, 1.0f);
}

MTWStruct ModelToWorld(
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _boneMatrix)
{
	MTWStruct res;

	float4x4 tmpMat = mul(_boneMatrix, mul(charaDatas.frameMatrix, charaDatas.worldMat));

	res.worldPos = mul(_pos, tmpMat);

	res.viewPos = mul(res.worldPos, drawData.viewMat);

	res.proPos = mul(res.viewPos, drawData.proMat);

	res.uv = _uv + charaDatas.moveUV;

	res.vertexNormal = normalize(mul(_normal, (float3x3)tmpMat));
	res.faceNormal = normalize(mul(_faceNormal, (float3x3)tmpMat));

	return res;
}

void FrustumCulling(float4 _pos)
{
	float x = _pos.x / _pos.w;
	x *= x;
	float y = _pos.y / _pos.w;
	y *= y;
	float z = (_pos.z / _pos.w) * 2.0f - 1.0f;
	z *= z;
	clip(1.0f - x);
	clip(1.0f - y);
	clip(1.0f - z);
}

void AlphaTest(float _alpha)
{
	clip(_alpha - charaDatas.alphaTestValue);
}


#endif

#endif