#ifndef ChShader_PublicHeader_Light
#define ChShader_PublicHeader_Light

//#define __SHADER__をhlsl側で定義する//

#include"../ShaderPublicInclude.hlsli"

#ifndef LIGHT_PLIGHTCOUNT
#define LIGHT_PLIGHTCOUNT 10
#endif

#ifndef LIGHT_DATA_REGISTERNO
#define LIGHT_DATA_REGISTERNO 10
#endif

#ifndef LIGHT_TEXTURE_REGISTERNO
#define LIGHT_TEXTURE_REGISTERNO 10
#endif

struct ChDirectionalLight
{
	//diffuse//
	float3 dif;
	bool useFlg;
	//direction//
	float3 dir;
	float ambPow;
};

struct ChPointLight
{
	float3 pos;
	float len;
	//diffuse//
	float3 dif;
	bool useFlg;
};


#ifdef __SHADER__
cbuffer LightData :register(CHANGE_CBUFFER(LIGHT_DATA_REGISTERNO))
#else
struct ChLightData
#endif
{
    float3 camPos = float3(0.0f, 0.0f, 0.0f);

    int colorType = 0;

    ChDirectionalLight light;

    ChPointLight pLight[LIGHT_PLIGHTCOUNT];
};

#ifdef __SHADER__

texture2D lightPowMap :register(CHANGE_TBUFFER(LIGHT_TEXTURE_REGISTERNO));

//画像から1ピクセルの色を取得するための物//
sampler lightSmp :register(CHANGE_SBUFFER(LIGHT_TEXTURE_REGISTERNO))
= sampler_state {
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

struct L_BaseColor
{
	float3 color;
	float3 wPos;
	float3 wfNormal;
	float4 specular;
};

float3 LamLightColBase(float3 _dif, float _pow);

float3 LamLightDirection(float3 _normal);

float3 LamLightPoint(float3 _dif, float _pow);

float3 SpeLightColBase(float _lcDot, float4 _speculer);

float3 SpeLightDirection(float3 _modelPos, float3 _normal, float4 _speculer);

float3 AmbLightCol();

float3 GetDirectionalLightColor(L_BaseColor _bCol)
{
	float3 oCol = _bCol.color;

	if (!light.useFlg)return oCol;

	oCol += LamLightDirection(_bCol.wfNormal);

	oCol += SpeLightDirection(_bCol.wPos, _bCol.wfNormal, _bCol.specular);

	return oCol;
}

float3 LamLightDirection(float3 _normal)
{
	float dotSize = dot(normalize(_normal), normalize(-light.dir));

	float4 lamPowMapCol = lightPowMap.Sample(lightSmp, float2(dotSize, dotSize));

	float lamPow = lamPowMapCol[colorType];

	if(dotSize > light.ambPow)return light.dif *  light.ambPow;

	//dotSize = dotSize > light.ambPow ? dotSize : light.ambPow;

	float3 resultCol =  LamLightColBase(light.dif, lamPow);

	return resultCol;
}

float3 LamLightPoint(float3 _dif, float _pow)
{
	
}

float3 SpeLightDirection( float3 _modelPos, float3 _normal, float4 _speculer)
{

	float3 tmpVec = normalize(camPos.xyz - _modelPos) + normalize(-light.dir);

	tmpVec = normalize(tmpVec);

	float lcDot = dot(tmpVec, _normal);

	return SpeLightColBase(lcDot, _speculer);
}

float3 LamLightColBase(float3 _dif, float _pow)
{

	float3 tmpLightCol = _dif;

	tmpLightCol *= _pow;

	return tmpLightCol;
}

float3 SpeLightColBase(float _lcDot, float4 _speculer)
{

	float power = saturate(_lcDot);

	float3 tmpLightCol = _speculer.rgb * pow(power, _speculer.a);

	return tmpLightCol;
}

#endif

#endif