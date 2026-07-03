#ifndef ChShader_PublicHeader_BasicShapes
#define ChShader_PublicHeader_BasicShapes

//#define __SHADER__をhlsl側で定義する//

#include"ShaderPublicInclude.hlsli"

#ifndef CH_BS_MAX_POSITION_DATA
#define CH_BS_MAX_POSITION_DATA 13
#endif

#ifndef CH_BS_MAX_CIRCLE_DATA
#define CH_BS_MAX_CIRCLE_DATA 13
#endif

struct ChBasicShapesPositions
{
    float4 positions[CH_BS_MAX_POSITION_DATA];
	uint usePositionCount;
	float3 tmp;//パッキング用//
};

struct ChBasicShapesCircleData
{
	float2 centerPosition;
	float size;
	float tmp;//パッキング用//
};

struct ChBasicShapesCircleDatas
{
    ChBasicShapesCircleData datas[CH_BS_MAX_CIRCLE_DATA];
	int usePositionCount;
	float3 tmp;//パッキング用//
};

#ifdef __SHADER__

int IsInPosition(ChBasicShapesPositions _positions, float2 _uv)
{
	if (_positions.usePositionCount <= 0)return -1;

	float3 tmpUVPos = float3(_uv.x, 0.0f, _uv.y);
	
	uint i = 0;
	float3 crossDir = 0.0f;
	float3 basePos = 0.0f;
	float3 nextPos = 0.0f;
	uint tmpValue = 0;
	for (i = 0; i < _positions.usePositionCount && i < CH_BS_MAX_POSITION_DATA; i++)
	{
		tmpValue = (i + 1) % _positions.usePositionCount;
		basePos = float3(_positions.positions[i].x, 0.0f, _positions.positions[i].y);
		nextPos = float3(_positions.positions[tmpValue].x, 0.0f, _positions.positions[tmpValue].y);
		
		crossDir = cross(nextPos - basePos, tmpUVPos - basePos);
		if (crossDir.y < 0.0f)continue;
		return -1;
	}

	return 1;
}

int IsInCirclePosition(ChBasicShapesCircleDatas _circleDatas, float2 _uv)
{
	if (_circleDatas.usePositionCount <= 0)return -1;
	
	float2 tmpVec = 0.0f;
	float tmpLen = 0.0f; 
	float tmpSize = 0.0f;
	int i = 0;

	for (i = 0; i < _circleDatas.usePositionCount && i < CH_BS_MAX_CIRCLE_DATA; i++)
	{
		tmpVec = _uv - _circleDatas.datas[i].centerPosition;
		tmpSize = _circleDatas.datas[i].size * _circleDatas.datas[i].size;
		tmpLen = tmpVec.x * tmpVec.x + tmpVec.y * tmpVec.y;
		if (tmpLen > tmpSize)continue;
		return 1;
	}
	
	return -1;
}

#endif

#endif