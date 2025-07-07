#ifndef Ch_D3DOI_h
#define Ch_D3DOI_h

#ifdef _WINDOWS_

#include<XInput.h>
#include<xaudio2.h>
#include<d2d1.h>
#include<dwrite.h>

#include"../Direct3DObject/XInputController/ChXInputController.h"
#include"../Direct3DObject/XAudios/ChXAudio.h"
#include"../Direct3DObject/WICBitmapCreator/ChWICBitmapCreator.h"
#include"../Direct3DObject/DirectFont/ChDirectFont.h"

#ifdef _DEBUG

#ifdef _DLL
#pragma comment(lib,"ChD3DObjectLibrary_MDd.lib")
#else
#pragma comment(lib,"ChD3DObjectLibrary_MTd.lib")
#endif

#else

#ifdef _DLL
#pragma comment(lib,"ChD3DObjectLibrary_MD.lib")
#else
#pragma comment(lib,"ChD3DObjectLibrary_MT.lib")
#endif

#endif



#endif
#endif