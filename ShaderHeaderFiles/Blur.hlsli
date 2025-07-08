#ifndef ChShader_PublicHeader_BLUR
#define ChShader_PublicHeader_BLUR

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"

#include"Texture/BaseTexture.hlsli"

#ifndef BLUR_DATA_REGISTERNO
#define BLUR_DATA_REGISTERNO 1
#endif

#ifdef __SHADER__
cbuffer BlurData : register(CHANGE_CBUFFER(BLUR_DATA_REGISTERNO))
#else
struct ChS_Blur
#endif
{
    float2 windowSize = float2(0.0f, 0.0f);
    int blurPower = 5;
    int liteBlurFlg = 0;
};

#ifdef __SHADER__

float4 Blur(float2 _uv)
{
    float4 resultColor = GetBaseTextureColor(_uv);
    float baseWidth = windowSize.x > 0.0f ? 1.0f / windowSize.x : 1.0f;
    float baseHeight = windowSize.y > 0.0f ? 1.0f / windowSize.y : 1.0f;
    
    bool liteFlg = liteBlurFlg == 1;
    int mulCount = liteFlg ? 2 : 4;

    for (int i = 1; i < blurPower;i++)
    {
        resultColor += GetBaseTextureColor(float2(_uv.x + (baseWidth * i), _uv.y));
        resultColor += GetBaseTextureColor(float2(_uv.x, _uv.y + (baseHeight * i)));
        if(liteFlg)continue;
        resultColor += GetBaseTextureColor(float2(_uv.x + (baseWidth * -i), _uv.y));
        resultColor += GetBaseTextureColor(float2(_uv.x, _uv.y + (baseHeight * -i)));
    }
    resultColor /= float((blurPower * mulCount) + 1);
    
    return resultColor;
}

#endif

#endif