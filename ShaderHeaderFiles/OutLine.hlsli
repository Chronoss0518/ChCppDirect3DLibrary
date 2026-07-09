#ifndef ChShader_PublicHeader_OL
#define ChShader_PublicHeader_OL

#include"ShaderPublicInclude.hlsli"

#ifndef CH_OL_OUTLINE_DATA_REGISTERNO
#define CH_OL_OUTLINE_DATA_REGISTERNO 12
#endif

#ifdef __SHADER__
cbuffer OutLineData :register(CH_CHANGE_CBUFFER(CH_OL_OUTLINE_DATA_REGISTERNO))
#else
struct ChOutLineData
#endif
{
    float width = 0.1f;
    float3 tmp;
    float4 outlineColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
};


#ifdef __SHADER__

float4 GetOutLinePos(float4 _worldPos,float3 _normal)
{
    return float4(_worldPos.xyz + _normal * width,_worldPos.w);
}

float4 GetOutLineColor()
{
    return outlineColor;
}

#endif

#endif