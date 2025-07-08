#ifndef ChShader_PublicHeader_Highlight
#define ChShader_PublicHeader_Highlight

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"../ShaderPublicInclude.hlsli"

#include"Texture/BaseTexture.hlsli"

#ifndef HIGHLIGHT_DATA_REGISTERNO
#define HIGHLIGHT_DATA_REGISTERNO 1
#endif

#ifndef HIGHLIGHT_SAMPLER_REGISTERNO
#define HIGHLIGHT_SAMPLER_REGISTERNO 1
#endif

#ifdef __SHADER__
cbuffer BlurData : register(CHANGE_CBUFFER(HIGHLIGHT_DATA_REGISTERNO))
#else
struct ChS_HighLight
#endif
{
    float2 windowSize = float2(0.0f, 0.0f);
    int blurPower = 5;
    int liteBlurFlg = 0;
    float boostPower = 1.0f;
    float3 tmp = 0.0f;
};

#ifdef __SHADER__


sampler highLightSmp : register(CHANGE_SBUFFER(HIGHLIGHT_SAMPLER_REGISTERNO));


float4 HighLightColor(float2 _uv)
{
    float4 resultColor = GetBaseTextureColor(_uv);
    float baseWidth = windowSize.x > 0.0f ? 1.0f / windowSize.x : 1.0f;
    float baseHeight = windowSize.y > 0.0f ? 1.0f / windowSize.y : 1.0f;
    
    bool liteFlg = liteBlurFlg == 1;
    int mulCount = liteFlg ? 2 : 4;

    for (int i = 1; i < blurPower;i++)
    {
        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x + (baseWidth * i), _uv.y),highLightSmp);
        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x, _uv.y + (baseHeight * i)),highLightSmp);

        if(liteFlg)continue;

        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x + (baseWidth * -i), _uv.y),highLightSmp);
        resultColor += GetBaseTextureColorFromSampler(float2(_uv.x, _uv.y + (baseHeight * -i)),highLightSmp);
    }
    resultColor.rgb /= float((blurPower - 1.0f) * mulCount);
    resultColor.rgb *= boostPower;
    resultColor.r = resultColor.r > 1.0f ? 1.0f : resultColor.r * resultColor.r;  
    resultColor.g = resultColor.g > 1.0f ? 1.0f : resultColor.g * resultColor.g;  
    resultColor.b = resultColor.b > 1.0f ? 1.0f : resultColor.b * resultColor.b;  
    resultColor.a = 1.0f;
    //resultColor.a = resultColor.r / 3.0f  + resultColor.g / 3.0f + resultColor.b / 3.0f;
    return resultColor;
}

#endif

#endif