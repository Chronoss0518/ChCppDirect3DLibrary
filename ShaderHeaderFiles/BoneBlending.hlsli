#ifndef ChShader_PublicHeader_BoneBlending
#define ChShader_PublicHeader_BoneBlending

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"

#ifndef BONE_DATA_REGISTERNO
#define BONE_DATA_REGISTERNO 11
#endif

#ifndef BONE_MAX_NUM
#define BONE_MAX_NUM 16
#endif

#ifdef __SHADER__
#ifdef _SM5_0_
cbuffer BoneData :register(CHANGE_CBUFFER(BONE_DATA_REGISTERNO))
#else
struct BoneData
#endif
#else
struct ChBoneData
#endif
{
    row_major float4x4 boneOffsetMat[BONE_MAX_NUM];
    row_major float4x4 boneMat[BONE_MAX_NUM];
};

#ifdef __SHADER__

#ifndef _SM5_0_

float4x4 BlendMatrix(BoneData _data,float4x4 _blendPow, uint _blendNum)
{
    float4x4 res = GetInitMatrix4x4();

	uint first = 0;
	uint second = 0;

	for (uint i = 0; i < _blendNum && i < BONE_MAX_NUM; i++)
	{
		first = i / 4;
		second = i % 4;
		
        res += mul(_data.boneOffsetMat[i],_data.boneMat[i]) * _blendPow[first][second];
	}

	return res;
}

#else

float4x4 BlendMatrix(float4x4 _blendPow, uint _blendNum)
{
    float4x4 res = GetInitMatrix4x4();

	uint first = 0;
	uint second = 0;

	for (uint i = 0; i < _blendNum && i < BONE_MAX_NUM; i++)
	{
		first = i / 4;
		second = i % 4;
		
        res += mul(boneOffsetMat[i],boneMat[i]) * _blendPow[first][second];
	}

	return res;
}

#endif

#endif

#endif