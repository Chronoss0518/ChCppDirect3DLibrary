#ifndef ChShader_PublicHeader_DP
#define ChShader_PublicHeader_DP

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"

#ifndef DRAW_DATA_REGISTERNO
#define DRAW_DATA_REGISTERNO 0
#endif

#ifndef CHARACTOR_DATA_REGISTERNO
#define CHARACTOR_DATA_REGISTERNO 1
#endif

#ifndef MATERIAL_DATA_REGISTERNO 
#define MATERIAL_DATA_REGISTERNO 2
#endif

#ifndef ChP_MAX_INSTANCE_COUNT
#define ChP_MAX_INSTANCE_COUNT 100
#endif

struct ChP_DrawData
{
	row_major float4x4 viewMat;

    row_major float4x4 proMat;
    
	float alphaTestValue;
	
    float3 drawDataTmp;
};

struct ChP_CharaData
{
	row_major float4x4 worldMat;

	row_major float4x4 frameMatrix;
	
    float2 moveUV;
	
    float2 charaDataTmp;
};

struct ChP_Material
{
    float4 diffuse;
    float3 specularCol;
    float specularPow;
    float4 ambient;
};

#ifdef __SHADER__

cbuffer DrawData :register(CHANGE_CBUFFER(DRAW_DATA_REGISTERNO))
{
	ChP_DrawData drawData;
};

cbuffer CharaData :register(CHANGE_CBUFFER(CHARACTOR_DATA_REGISTERNO))
{
	ChP_CharaData charaDatas[CHP_MAX_INSTANCE_COUNT];
};

cbuffer Material:register(CHANGE_CBUFFER(MATERIAL_DATA_REGISTERNO))
{
	uniform ChP_Material mate[CHP_MAX_INSTANCE_COUNT];
};

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
	float4x4 _frameMatrix)
{
	MTWStruct res;

	float4x4 tmpMat = mul(_frameMatrix, charaDatas.worldMat);

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