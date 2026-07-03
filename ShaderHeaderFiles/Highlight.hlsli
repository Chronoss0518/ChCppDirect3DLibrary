#ifndef ChShader_PublicHeader_Highlight
#define ChShader_PublicHeader_Highlight

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"

#include"Texture/BaseTexture.hlsli"

#ifndef CH_HL_HIGHLIGHT_DATA_REGISTERNO
#define CH_HL_HIGHLIGHT_DATA_REGISTERNO 1
#endif

struct ChHighLightData
{
    float2 windowSize
#ifdef __cplusplus
    = float2(0.0f, 0.0f)
#endif
    ;
    int blurPower
#ifdef __cplusplus
    = 5
#endif
    ;
    int liteBlurFlg
#ifdef __cplusplus
    = 0
#endif
    ;
    float boostPower
#ifdef __cplusplus
    = 1.0f
#endif
    ;
    float3 nonData;
};

#ifdef __SHADER__

float4 HighLightColorBase(ChHighLightData _data,float2 _uv);

#ifndef _SM5_0_

float4 HighLightColor(ChHighLightData _data,float2 _uv)
{
    return HighLightColorBase(_data,_uv);
}

#else

cbuffer HighLightData : register(CH_CHANGE_CBUFFER(CH_HL_HIGHLIGHT_DATA_REGISTERNO))
{
    ChHighLightData highLightData; 
};

float4 HighLightColor(float2 _uv)
{
    return HighLightColorBase(highLightData,_uv);
}

#endif

float4 HighLightColorBase(ChHighLightData _data,float2 _uv)
{
    float4 resultColor = GetBaseTextureColorFromSampler(_uv,baseSmp);
    float baseWidth = _data.windowSize.x > 0.0f ? 1.0f / _data.windowSize.x : 1.0f;
    float baseHeight = _data.windowSize.y > 0.0f ? 1.0f / _data.windowSize.y : 1.0f;
    
    bool liteFlg = _data.liteBlurFlg == 1;
    int mulCount = liteFlg ? 2 : 4;

    for (int i = 1; i < _data.blurPower;i++)
    {
        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x + (baseWidth * i), _uv.y),baseSmp);
        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x, _uv.y + (baseHeight * i)),baseSmp);

        if(liteFlg)continue;

        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x + (baseWidth * -i), _uv.y),baseSmp);
        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x, _uv.y + (baseHeight * -i)),baseSmp);
    }
    resultColor.rgb /= float((_data.blurPower - 1.0f) * mulCount);
    resultColor.rgb *= _data.boostPower;
    resultColor.r = resultColor.r > 1.0f ? 1.0f : resultColor.r * resultColor.r;  
    resultColor.g = resultColor.g > 1.0f ? 1.0f : resultColor.g * resultColor.g;  
    resultColor.b = resultColor.b > 1.0f ? 1.0f : resultColor.b * resultColor.b;  
    resultColor.a = 1.0f;
    //resultColor.a = resultColor.r / 3.0f  + resultColor.g / 3.0f + resultColor.b / 3.0f;
    return resultColor;
}



#endif

#endif