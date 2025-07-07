#ifdef _WINDOWS_

#ifndef Ch_BD11I_h
#define Ch_BD11I_h

#include<D3D11.h>
#include<direct.h>
#include<d3dcompiler.h>
#include<DXGI.h>


#pragma comment(lib,"d3d11.lib")
//#pragma comment(lib,"d3dx11.lib")
#pragma comment(lib, "dxguid.lib")

#include"../Direct3D11/ChPackDate/ChMatrix_11.h"
#include"../Direct3D11/ChPackDate/ChVector3_11.h"
#include"../Direct3D11/ChPackDate/ChQuaternion_11.h"
#include"../Direct3D11/ChDirectX11Controller/ChDirectX11Controller.h"
#include"../Direct3D11/ChShaderStructures11.h"

#endif

#ifndef CH_STRING_TYPE_USE_D3D11_MESH_EXPLICIT_DECLARATION
#define CH_STRING_TYPE_USE_D3D11_MESH_EXPLICIT_DECLARATION(_Class)\
template class _Class<wchar_t>
#endif


#endif