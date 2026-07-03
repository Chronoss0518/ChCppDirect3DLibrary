#ifndef ChShader_PublicHeader_BoneBlending
#define ChShader_PublicHeader_BoneBlending

//#define __SHADER__‚ðhlsl‘¤‚Å’è‹`‚·‚é//

#include"ShaderPublicInclude.hlsli"

#ifndef CH_BB_BONE_DATA_REGISTERNO
#define CH_BB_BONE_DATA_REGISTERNO 11
#endif

#ifndef CH_BB_BONE_MAX_NUM
#define CH_BB_BONE_MAX_NUM 16
#endif

struct ChBoneData
{
    row_major float4x4 boneOffsetMat[CH_BB_BONE_MAX_NUM];
    row_major float4x4 boneMat[CH_BB_BONE_MAX_NUM];
};

#ifdef __SHADER__

float4x4 BlendMatrixBase(ChBoneData _data,float4x4 _blendPow, uint _blendNum);

#ifndef _SM5_0_

float4x4 BlendMatrix(ChBoneData _data,float4x4 _blendPow, uint _blendNum)
{
	return BlendMatrixBase(_data,_blendPow,_blendNum);
}

#else

cbuffer BoneData :register(CH_CHANGE_CBUFFER(CH_BB_BONE_DATA_REGISTERNO))
{
	ChBoneData boneData;
};

float4x4 BlendMatrix(float4x4 _blendPow, uint _blendNum)
{
	return BlendMatrixBase(boneData,_blendPow,_blendNum);
}

#endif

float4x4 BlendMatrixBase(ChBoneData _data,float4x4 _blendPow, uint _blendNum)
{
    float4x4 res = GetInitMatrix4x4();

	uint first = 0;
	uint second = 0;

	for (uint i = 0; i < _blendNum && i < CH_BB_BONE_MAX_NUM; i++)
	{
		first = i / 4;
		second = i % 4;
		
        res += mul(_data.boneOffsetMat[i],_data.boneMat[i]) * _blendPow[first][second];
	}

	return res;
}

#endif

#endif