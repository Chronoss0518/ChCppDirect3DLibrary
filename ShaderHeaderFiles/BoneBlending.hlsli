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
cbuffer BoneData :register(CHANGE_CBUFFER(BONE_DATA_REGISTERNO))
#else
struct ChBoneData
#endif
{
    row_major float4x4 skinWeightMat[BONE_MAX_NUM];
    row_major float4x4 boneOffsetMat[BONE_MAX_NUM];
    row_major float4x4 boneOffsetInverseMat[BONE_MAX_NUM];
};

#ifdef __SHADER__

float4x4 BlendMatrix(float4x4 _blendPow, uint _blendNum)
{
	float4x4 blendMat;

	float4x4 tmpBoneOffsetMat = boneOffsetMat[_blendNum - 1];
	float4x4 tmpBoneOffsetInverseMat;

	uint first = 0;
	uint second = 0;

	for (uint i = 0; i < _blendNum && i < BONE_MAX_NUM; i++)
	{
		first = i / 4;
		second = i % 4;

		tmpBoneOffsetMat = mul(boneOffsetMat[i], tmpBoneOffsetMat);
		tmpBoneOffsetInverseMat = mul(boneOffsetInverseMat[i], tmpBoneOffsetInverseMat);

		if (_blendPow[first][second] <= 0.0f)continue;

		blendMat += mul(skinWeightMat[i],_blendPow[first][second]);
		
	}

	//blendMat = mul(tmpBoneOffsetInverseMat, mul(blendMat, tmpBoneOffsetMat));
	blendMat = mul(tmpBoneOffsetInverseMat, tmpBoneOffsetMat);


	return blendMat;


}
#endif

#endif