
#ifndef ChShader_PublicHeader_Base_Texture
#define ChShader_PublicHeader_Base_Texture

#ifndef BASE_TEXTURE_REGISTER
#define	BASE_TEXTURE_REGISTER 0
#endif

#ifdef __SHADER__

#include"../ShaderPublicInclude.hlsli"

texture2D baseTex : register(CHANGE_TBUFFER(BASE_TEXTURE_REGISTER));

sampler baseSmp : register(CHANGE_SBUFFER(BASE_TEXTURE_REGISTER));

float4 GetBaseTextureColor(float2 _uv)
{
    float4 res = baseTex.Sample(baseSmp, _uv);
    res.a = min(res.a,1.0f);
    return res;
}

float4 GetBaseTextureColorFromSampler(float2 _uv, sampler _sampler)
{
    float4 res = baseTex.Sample(_sampler, _uv);
    res.a = min(res.a,1.0f);
    return res;
}

#endif

#endif