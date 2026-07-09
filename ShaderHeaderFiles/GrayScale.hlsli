#ifndef ChShader_PublicHeader_DT
#define ChShader_PublicHeader_DT

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"../ShaderPublicInclude.hlsli"

#ifndef CH_GS_GRAY_SCALE_DATA_REGISTERNO
#define CH_GS_GRAY_SCALE_DATA_REGISTERNO 2
#endif

#ifndef CH_GS_GRAY_SCALE_TEXTURE_REGISTER
#define	CH_GS_GRAY_SCALE_TEXTURE_REGISTER 2
#endif

#ifdef __SHADER__
cbuffer GrayScaleData : register(CH_CHANGE_CBUFFER(CH_GS_GRAY_SCALE_DATA_REGISTERNO))
#else
struct ChS_GrayScale
#endif
{
    
};


#ifdef __SHADER__
texture2D grayScaleTex : register(CH_CHANGE_TBUFFER(CH_GS_GRAY_SCALE_TEXTURE_REGISTER));

sampler grayScaleSmp :register(CH_CHANGE_SBUFFER(CH_GS_GRAY_SCALE_TEXTURE_REGISTER));
#endif

#endif
