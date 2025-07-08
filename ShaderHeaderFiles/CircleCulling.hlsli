#ifndef ChShader_PublicHeader_CircleCulling
#define ChShader_PublicHeader_CircleCulling

//#define __SHADER__をhlsl側で定義する//

#include"../ShaderPublicInclude.hlsli"

#ifndef CIRCLE_CULLING_DATA
#define CIRCLE_CULLING_DATA 6
#endif

#ifdef __SHADER__
cbuffer ChCircleCullingData :register(CHANGE_CBUFFER(CIRCLE_CULLING_DATA))
#else
struct ChCircleCullingData
#endif
{
	float2 drawStartDir = float2(0.0f, 1.0f);
	float2 centerPos = float2(0.0f, 0.0f);
	float drawValue = 1.0f;//-1～1のサイズの数値(負の値だった場合は反時計回りになる)//
	float3 nonData;//バイト合わせ//
};

#ifdef __SHADER__

float maxValue = 1.0f;

//このメソッドの内部でclipを行っており、成功するとdiscardされずに描画される//
void CircleCullingTest(float2 _uv)
{
	float3 useDrawStartDir = float3(drawStartDir.x, 0.0f, drawStartDir.y);
	useDrawStartDir = normalize(useDrawStartDir);

	float3 useUVPos = float3(_uv.x - centerPos.x, 0.0f, _uv.y - centerPos.y);

	useUVPos.xz = useUVPos.xz * 2.0f - 1.0f;

	useUVPos = normalize(useUVPos);
	
	if (length(useUVPos) <= 0.0f)return;

	float uvPosRadian = dot(useDrawStartDir, useUVPos);

	float3 uvNormalDir = cross(useDrawStartDir, useUVPos);

	uvPosRadian = uvNormalDir.y > 0 ? (uvPosRadian - 1.0f) * -0.25f : (uvPosRadian + 1.0f) * 0.25f + 0.5f;

	float useDrawValue = drawValue * maxValue;
	
	clip(useDrawValue > 0 ? useDrawValue - uvPosRadian : (uvPosRadian) - (maxValue + useDrawValue));
}

#endif

#endif