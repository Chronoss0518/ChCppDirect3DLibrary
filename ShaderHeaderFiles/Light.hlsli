#ifndef ChShader_PublicHeader_Light
#define ChShader_PublicHeader_Light

//#define __SHADER__をhlsl側で定義する//

#include"ShaderPublicInclude.hlsli"

#ifndef CH_L_LIGHT_PLIGHTCOUNT
#define CH_L_LIGHT_PLIGHTCOUNT 10
#endif

#ifndef CH_LL_LIGHT_DATA_REGISTERNO
#define CH_LL_LIGHT_DATA_REGISTERNO 10
#endif

#ifndef CH_L_LIGHT_TEXTURE_REGISTERNO
#define CH_L_LIGHT_TEXTURE_REGISTERNO 10
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


struct ChLightData
{
    float3 camPos
#ifdef __cplusplus
	= float3(0.0f, 0.0f, 0.0f)
#endif
	;

    int colorType
#ifdef __cplusplus
	= 0
#endif
	;

    ChDirectionalLight light;

    ChPointLight pLight[CH_L_LIGHT_PLIGHTCOUNT];
};

#ifdef __SHADER__

struct L_BaseColor
{
	float3 color;
	float3 wPos;
	float3 wfNormal;
	float4 specular;
};

float3 GetLightColorBase(ChLightData _data, L_BaseColor _bCol);

#ifndef _SM5_0_

texutre lightPowMap :register(CH_CHANGE_TBUFFER(CH_L_LIGHT_TEXTURE_REGISTERNO));

//画像から1ピクセルの色を取得するための物//
sampler lightSmp = sampler_state {
    Texture = <lightPowMap>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
};

float4 GetLightPowTextureColor(float2 _uv)
{
    float4 res = tex2D(lightSmp, _uv);
    res.a = min(res.a,1.0f);
    return res;
}

float3 GetLightColor(ChLightData _data,L_BaseColor _bCol)
{
	return GetLightColorBase(_data, _bCol);
}

#else

texture2D lightPowMap :register(CH_CHANGE_TBUFFER(CH_L_LIGHT_TEXTURE_REGISTERNO));

//画像から1ピクセルの色を取得するための物//
sampler lightSmp : register(CH_CHANGE_SBUFFER(CH_L_LIGHT_TEXTURE_REGISTERNO))
= sampler_state {
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
};

cbuffer LightData :register(CH_CHANGE_CBUFFER(CH_LL_LIGHT_DATA_REGISTERNO))
{
	ChLightData lightData;
};

float4 GetLightPowTextureColor(float2 _uv)
{
    float4 res = lightPowMap.Sample(lightSmp, _uv);
    res.a = min(res.a,1.0f);
    return res;
}

float3 GetLightColor(L_BaseColor _bCol)
{
	return GetLightColorBase(lightData, _bCol);
}

#endif

float LamLightColPowerBase(float3 _normal, float3 _lightDir,int _colorType);

float3 LamLightDirection(ChLightData _data, float3 _modelPos, float3 _normal, float4 _speculer, float3 _baseCol);

float3 LamLightPoint(float3 _dif, float _pow);

float3 SpeLightColBase(float3 _modelPos, float3 _normal, float4 _speculer, float3 _lightDir, float3 _camPos);

float3 AmbLightCol();

float3 GetLightColorBase(ChLightData _data, L_BaseColor _bCol)
{
    float3 oCol = _bCol.color;

    if (!_data.light.useFlg)
        return oCol;

    oCol = LamLightDirection(_data,_bCol.wPos, _bCol.wfNormal, _bCol.specular, oCol);

    return oCol;
}

float3 LamLightDirection(ChLightData _data, float3 _modelPos, float3 _normal, float4 _speculer, float3 _baseCol)
{
    float lamPow = LamLightColPowerBase(_normal, _data.light.dir, _data.colorType);

    float3 resultCol = saturate(_data.light.dif * lamPow + _data.light.dif * _data.light.ambPow) * _baseCol;

    resultCol += SpeLightColBase(_modelPos, _normal, _speculer, _data.light.dir, _data.camPos);

    return resultCol;
}

float3 LamLightPoint(float3 _dif, float _pow)
{
	
}

float LamLightColPowerBase(float3 _normal, float3 _lightDir,int _colorType)
{
    float dotSize = dot(normalize(_normal), normalize(-_lightDir));
	
    return GetLightPowTextureColor(float2(dotSize, dotSize))[_colorType];
}

float3 SpeLightColBase(float3 _modelPos, float3 _normal, float4 _speculer, float3 _lightDir,float3 _camPos)
{
    float3 tmpVec = normalize(_camPos - _modelPos) + normalize(-_lightDir);

    tmpVec = normalize(tmpVec);

    float lcDot = dot(tmpVec, _normal);

    float power = saturate(lcDot);

    float3 tmpLightCol = _speculer.rgb * pow(power, _speculer.a);

    return tmpLightCol;
}

#endif

#endif