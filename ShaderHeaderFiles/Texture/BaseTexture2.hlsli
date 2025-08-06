
#ifndef ChShader_PublicHeader_Base_Texture
#define ChShader_PublicHeader_Base_Texture

#ifndef BASE_TEXTURE_REGISTER
#define	BASE_TEXTURE_REGISTER 0
#endif

#ifdef __SHADER__

#include"../ShaderPublicInclude.hlsli"

Texture2DArray baseTex : register(CHANGE_TBUFFER(BASE_TEXTURE_REGISTER));

SamplerState baseSmp : register(CHANGE_SBUFFER(BASE_TEXTURE_REGISTER));

float4 GetBaseTextureColorFromNo(float2 _uv,uint _no)
{
    float4 res = baseTex.Sample(baseSmp, float3(_uv,_no));
    res.a = min(res.a,1.0f);
    return res;
}

float4 GetBaseTextureColorFromSamplerAndNo(float2 _uv, sampler _sampler,uint _no)
{
    float4 res = baseTex.Sample(_sampler, float3(_uv,_no));
    res.a = min(res.a,1.0f);
    return res;
}

float4 GetBaseTextureColor(float2 _uv)
{
    float4 res = baseTex.Sample(baseSmp, float3(_uv,0.0f));
    res.a = min(res.a,1.0f);
    return res;
}

float4 GetBaseTextureColorFromSampler(float2 _uv, sampler _sampler)
{
    float4 res = baseTex.Sample(_sampler, float3(_uv,0.0f));
    res.a = min(res.a,1.0f);
    return res;
}

#endif

#endif