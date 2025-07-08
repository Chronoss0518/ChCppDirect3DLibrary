#include<Windows.h>
#include<Xinput.h>

#include"../../../ChCppBaseLibrary/BaseIncluder/ChBase.h"

#include"ChXInputController.h"

#pragma comment(lib,"xinput.lib")

using namespace ChD3D;

ChCpp::BitBool XInputController::controllerFlgs;

XInputController::XInputController()
{
	ChStd::MZero(&state);
}

void XInputController::Init()
{
	unsigned char tmp = 0;

	for (unsigned char i = 0; i < 4; i++)
	{
		XINPUT_STATE tmp = { 0,{0,0,0,0,0,0,0} };

		XInputGetState(i, &tmp);

		if (tmp.dwPacketNumber <= 0)continue;

		if (controllerFlgs.GetBitFlg(i))continue;

		myNo = i;
		controllerFlgs.SetBitTrue(i);
		break;
	}

	SetInitFlg(true);

}

void XInputController::Release()
{
	ChStd::MZero(&state);

	controllerFlgs.SetBitFalse(myNo);
	myNo = 5;

	SetInitFlg(false);
}

void XInputController::Update()
{
	if (!*this) return;

	ChStd::MZero(&state);

	XInputGetState(myNo, &state);

	XInputSetState(myNo, &vibFlgs);

}

float XInputController::LDeadZoneTest(const float _sThumb)
{
	float Out = ChMath::GetAbs(_sThumb) < XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE ? 0.0f : _sThumb / 32767.0f;
	
	return Out;
}

float XInputController::RDeadZoneTest(const float _sThumb)
{

	float Out = ChMath::GetAbs(_sThumb) < XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE ? 0.0f : _sThumb / 32767.0f;

	return Out;
}

float XInputController::RL2DeadZoneTest(const unsigned char _sButton)
{
	float Out = ChMath::GetAbs(_sButton) < XINPUT_GAMEPAD_TRIGGER_THRESHOLD ? 0.0f : _sButton / 255.0f;

	return Out;
}