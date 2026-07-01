#ifndef ChShader_PublicHeader_BLUR
#define ChShader_PublicHeader_BLUR

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"

#include"Texture/BaseTexture.hlsli"

#ifndef BLUR_DATA_REGISTERNO
#define BLUR_DATA_REGISTERNO 1
#endif

struct ChBlurData
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
};


#ifdef __SHADER__

float4 BlurBase(ChBlurData _data,float2 _uv);

#ifndef _SM5_0_

float4 Blur(ChBlurData _data,float2 _uv)
{
    return BlurBase(_data,_uv);
}

#else

cbuffer BlurData : register(CHANGE_CBUFFER(BLUR_DATA_REGISTERNO))
{
    ChBlurData blurData;
};

float4 Blur(float2 _uv)
{
    return BlurBase(blurData,_uv);
}

#endif

float4 BlurBase(ChBlurData _data,float2 _uv)
{
    float4 resultColor = GetBaseTextureColor(_uv);
    float baseWidth = _data.windowSize.x > 0.0f ? 1.0f / _data.windowSize.x : 1.0f;
    float baseHeight = _data.windowSize.y > 0.0f ? 1.0f / _data.windowSize.y : 1.0f;
    
    bool liteFlg = _data.liteBlurFlg == 1;
    int mulCount = liteFlg ? 2 : 4;

    for (int i = 1; i < _data.blurPower;i++)
    {
        resultColor += GetBaseTextureColor(float2(_uv.x + (baseWidth * i), _uv.y));
        resultColor += GetBaseTextureColor(float2(_uv.x, _uv.y + (baseHeight * i)));
        if(liteFlg)continue;
        resultColor += GetBaseTextureColor(float2(_uv.x + (baseWidth * -i), _uv.y));
        resultColor += GetBaseTextureColor(float2(_uv.x, _uv.y + (baseHeight * -i)));
    }
    resultColor /= float((_data.blurPower * mulCount) + 1);
    
    return resultColor;
}

#endif

#endif