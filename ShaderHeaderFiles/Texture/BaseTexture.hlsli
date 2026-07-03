
#ifndef ChShader_PublicHeader_Base_Texture
#define ChShader_PublicHeader_Base_Texture

#ifndef CH_BT_BASE_TEXTURE_REGISTER
#define CH_BT_BASE_TEXTURE_REGISTER 0
#endif

#ifdef __SHADER__

#include"../ShaderPublicInclude.hlsli"

#ifdef _SM5_0_

Texture2DArray baseTex : register(CH_CHANGE_TBUFFER(CH_BT_BASE_TEXTURE_REGISTER));

SamplerState baseSmp : register(CH_CHANGE_SBUFFER(CH_BT_BASE_TEXTURE_REGISTER));

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

#else

texutre baseTex : register(CH_CHANGE_TBUFFER(CH_BT_BASE_TEXTURE_REGISTER));

sampler baseSmp : register(CH_CHANGE_SBUFFER(CH_BT_BASE_TEXTURE_REGISTER))
=sampler_state
{
    Texture = <baseTex>;
    MipFilter = WRAP;
    MinFilter = WRAP;
    MagFilter = WRAP;
};

float4 GetBaseTextureColor(float2 _uv)
{
    float4 res = tex2D(baseSmp, _uv);
    res.a = min(res.a,1.0f);
    return res;
}

float4 GetBaseTextureColorFromSampler(float2 _uv, sampler _sampler)
{
    float4 res = tex2D(_sampler, _uv);
    res.a = min(res.a,1.0f);
    return res;
}

#endif
#endif

#endif