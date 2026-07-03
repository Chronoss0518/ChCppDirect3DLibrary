#ifndef ChShader_PublicHeader_DPBase
#define ChShader_PublicHeader_DPBase

#ifndef CH_DP_DRAW_DATA_REGISTERNO
#define CH_DP_DRAW_DATA_REGISTERNO 0
#endif

#ifndef CH_DP_MODEL_DATA_REGISTERNO
#define CH_DP_MODEL_DATA_REGISTERNO 1
#endif

#ifndef CH_DP_FRAME_DATA_REGISTERNO 
#define CH_DP_FRAME_DATA_REGISTERNO 2
#endif

#ifndef CH_DP_MATERIAL_DATA_REGISTERNO 
#define CH_DP_MATERIAL_DATA_REGISTERNO 3
#endif

struct ChDrawData
{
    row_major float4x4 viewMat;
    row_major float4x4 proMat;
    float alphaTestValue;
    float3 nonData;
};

struct ChModelData
{
    row_major float4x4 worldMat;
};

struct ChFrameData
{
    row_major float4x4 frameMatrix;
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
	
    float2 moveUV;
    float2 nonData;
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
	ChModelData _modelData,
	ChFrameData _frameData,
	float4 _pos,
	float2 _uv,
	float3 _normal,
	float3 _faceNormal,
	float4x4 _frameMatrix)
{
	MTWStruct res;

	float4x4 tmpMat = mul(_frameMatrix, _modelData.worldMat);

	res.worldPos = mul(_pos, tmpMat);

	res.viewPos = mul(res.worldPos, _drawData.viewMat);

	res.proPos = mul(res.viewPos, _drawData.proMat);

	res.uv = _uv + _frameData.moveUV;

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