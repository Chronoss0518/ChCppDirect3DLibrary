#ifndef ChShader_PublicHeader_DT
#define ChShader_PublicHeader_DT

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"../ShaderPublicInclude.hlsli"

#ifndef GRAY_SCALE_DATA_REGISTERNO
#define GRAY_SCALE_DATA_REGISTERNO 2
#endif

#ifndef GRAY_SCALE_TEXTURE_REGISTER
#define	GRAY_SCALE_TEXTURE_REGISTER 2
#endif

#ifdef __SHADER__
cbuffer GrayScaleData : register(CHANGE_CBUFFER(GRAY_SCALE_DATA_REGISTERNO))
#else
struct ChS_GrayScale
#endif
{
    
};


#ifdef __SHADER__
texture2D grayScaleTex : register(CHANGE_TBUFFER(GRAY_SCALE_TEXTURE_REGISTER));

sampler grayScaleSmp :register(CHANGE_SBUFFER(GRAY_SCALE_TEXTURE_REGISTER));
#endif

#endif
