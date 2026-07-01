#ifndef ChShader_PublicHeader_CircleCulling
#define ChShader_PublicHeader_CircleCulling

//#define __SHADER__をhlsl側で定義する//

#include"ShaderPublicInclude.hlsli"

#ifndef CIRCLE_CULLING_DATA
#define CIRCLE_CULLING_DATA 6
#endif

struct ChCircleCullingData
{
    float2 drawStartDir
#ifdef __cplusplus
	= float2(0.0f, 1.0f)
#endif
	;
    float2 centerPos
#ifdef __cplusplus
	= float2(0.0f, 0.0f)
#endif
	;
    float drawValue //-1～1のサイズの数値(負の値だった場合は反時計回りになる)//
#ifdef __cplusplus
	= 1.0f
#endif
	;
    float3 nonData; //バイト合わせ//
};

#ifdef __SHADER__
#ifdef _SM5_0_
cbuffer CircleCullingData :register(CHANGE_CBUFFER(CIRCLE_CULLING_DATA))
{
	ChCircleCullingData circleCullingData;
};
#endif
#endif

#ifdef __SHADER__

void CircleCullingTestBase(ChCircleCullingData _data,float2 _uv);

#ifndef _SM5_0_

//このメソッドの内部でclipを行っており、成功するとdiscardされずに描画される//
void CircleCullingTest(ChCircleCullingData _data,float2 _uv)
{
	CircleCullingTestBase(_data,_uv);
}

#else

//このメソッドの内部でclipを行っており、成功するとdiscardされずに描画される//
void CircleCullingTest(float2 _uv)
{
	CircleCullingTestBase(circleCullingData,_uv);
}

#endif

//このメソッドの内部でclipを行っており、成功するとdiscardされずに描画される//
void CircleCullingTestBase(ChCircleCullingData _data,float2 _uv)
{
	float maxValue = 1.0f;
	
	float3 useDrawStartDir = float3(_data.drawStartDir.x, 0.0f, _data.drawStartDir.y);
	useDrawStartDir = normalize(useDrawStartDir);

	float3 useUVPos = float3(_uv.x - _data.centerPos.x, 0.0f, _uv.y - _data.centerPos.y);

	useUVPos.xz = useUVPos.xz * 2.0f - 1.0f;

	useUVPos = normalize(useUVPos);
	
	if (length(useUVPos) <= 0.0f)return;

	float uvPosRadian = dot(useDrawStartDir, useUVPos);

	float3 uvNormalDir = cross(useDrawStartDir, useUVPos);

	uvPosRadian = uvNormalDir.y > 0 ? (uvPosRadian - 1.0f) * -0.25f : (uvPosRadian + 1.0f) * 0.25f + 0.5f;

	float useDrawValue = _data.drawValue * maxValue;
	
	clip(useDrawValue > 0 ? useDrawValue - uvPosRadian : (uvPosRadian) - (maxValue + useDrawValue));
}

#endif

#endif