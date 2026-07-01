#ifndef ChShader_PublicHeader_DPBase
#define ChShader_PublicHeader_DPBase

struct ChDrawData
{
    row_major float4x4 viewMat;

    row_major float4x4 proMat;
	
    float alphaTestValue;
	
    float3 nonData;
};

struct ChCharaData
{
    row_major float4x4 worldMat;

    row_major float4x4 frameMatrix;
	
    float2 moveUV;
	
    float2 nonData;
};

struct ChMaterial
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

//ModelToWorld Structure//
struct MTWStruct
{
	float3 vertexNormal;
	float3 faceNormal;
	float4 worldPos;
	float4 viewPos;
	float4 proPos;
	float2 uv;
};

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

MTWStruct ModelToWorldBase(
	ChDrawData _drawData,
	ChCharaData _charaData,
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix)
{
	MTWStruct res;

	float4x4 tmpMat = mul(_frameMatrix, _charaData.worldMat);

	res.worldPos = mul(_pos, tmpMat);

	res.viewPos = mul(res.worldPos, _drawData.viewMat);

	res.proPos = mul(res.viewPos, _drawData.proMat);

	res.uv = _uv + _charaData.moveUV;

	res.vertexNormal = normalize(mul(_normal, (float3x3)tmpMat));
	res.faceNormal = normalize(mul(_faceNormal, (float3x3)tmpMat));

	return res;
}

void AlphaTestBase(ChDrawData _data,float _alpha)
{
	clip(_alpha - _data.alphaTestValue);
}

#endif

#endif