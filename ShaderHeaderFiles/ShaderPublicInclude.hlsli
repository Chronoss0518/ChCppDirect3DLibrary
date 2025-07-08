#ifndef _HLSL_Shader_Public_
#define _HLSL_Shader_Public_

#ifdef __SHADER__

#ifndef CHANGE_BUFFER
#ifdef _SM5_0_
#define CHANGE_BUFFER(_buffer,_no) _buffer##_no
#else
#define CHANGE_BUFFER(_buffer,_no) _buffer[_no]
#endif
#endif

#ifndef CHANGE_CBUFFER
#define CHANGE_CBUFFER(_no) CHANGE_BUFFER(b,_no)
#endif

#ifndef CHANGE_TBUFFER
#define CHANGE_TBUFFER(_no) CHANGE_BUFFER(t,_no)
#endif

#ifndef CHANGE_SBUFFER
#define CHANGE_SBUFFER(_no) CHANGE_BUFFER(s,_no)
#endif

#else

#ifndef SHADER_TO_CPP
#define SHADER_TO_CPP

#ifndef row_major
#define row_major
#endif

#ifndef uniform
#define uniform
#endif

#ifndef column_major
#define column_major
#endif

using uint4x4 = ChMath::BaseMatrix4x4<unsigned int>;
using uint3 = ChMath::Vector3Base<unsigned int>;
using uint2 = ChMath::Vector2Base<unsigned int>;
using uint = unsigned int;
using float4x4 = ChLMat;
using float3x3 = ChLMat;
using float2x2 = ChLMat;
using float4 = ChVec4;
using float3 = ChVec3;
using float2 = ChVec2;

#endif
#endif

#endif