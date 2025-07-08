#include<Windows.h>

#include<x3daudio.h>
#include<mfapi.h>
#include <windows.h>
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <stdio.h>
#include <mferror.h>
#include<mfreadwrite.h>

#pragma comment(lib,"xaudio2.lib")
#pragma comment(lib,"mfplat.lib")
#pragma comment(lib,"mfreadwrite.lib")
#pragma comment(lib,"mfuuid.lib")

#include"../../../ChCppBaseLibrary/BaseIncluder/ChBase.h"

#include"ChXAudio.h"

using namespace ChD3D;

#define BASE_LENGTH 1000.0f

ChD3D::AudioObject::~AudioObject()
{
	Release();
}

void ChD3D::AudioObject::SetFileName(const wchar_t* _fileName)
{
	fileName = _fileName;
}

const wchar_t* ChD3D::AudioObject::GetFileName()
{
	return fileName.c_str();
}

void AudioObject::SetVolume(const float _Volume)
{
	if (!*this)return;
	voice->SetVolume(_Volume);
}

float AudioObject::GetVolume()
{
	float outVol = 0.0f;

	if (!*this)return outVol;

	voice->GetVolume(&outVol);

	return outVol;
}

void AudioObject::Play()
{
	if (!*this)return;

	voice->Start(0);
}

void AudioObject::Pause()
{
	if (!*this)return;

	voice->Stop();
}

void AudioObject::Stop()
{
	if (!*this)return;

	voice->Stop();

	voice->FlushSourceBuffers();

	manager->SubmitSourceBuffer(voice, GetFileName(), 0);
	manager->SubmitSourceBuffer(voice, GetFileName(), 1);

	nowPos = 1;
}

void AudioObject::Release()
{
	if (!*this)return;

	manager->RemoveAudios(this);

	voice->Stop();

	voice->DestroyVoice();

	voice = nullptr;

	SetInitFlg(false);
}

void AudioObject::Update()
{

	loopEndPos = loopEndPos >= manager->GetAudioDataCount(GetFileName()) ? manager->GetAudioDataCount(GetFileName()) : loopEndPos;

	loopStartPos = loopStartPos >= loopEndPos ? 0 : loopStartPos;

	XAUDIO2_VOICE_STATE state;
	voice->GetState(&state);

	if (state.BuffersQueued >= 2)return;
	bool loopFlg = false;
	size_t testNowPos = nowPos;
	testNowPos = testNowPos + 1 >= loopEndPos ? loopStartPos : testNowPos + 1;

	if (testNowPos <= 0)loopFlg = true;

	if (!loopFlg && loopFlg)return;

	nowPos = testNowPos;

	manager->SubmitSourceBuffer(voice, GetFileName(), nowPos);
}

void X3DAudioObject::Init()
{
	Release();

	emitter = new X3DAUDIO_EMITTER();
	ChStd::MZero(emitter);

	emitter->ChannelCount = 1;
	emitter->CurveDistanceScaler = emitter->DopplerScaler = 1.0f;
	emitter->pCone = nullptr;
}

void X3DAudioObject::Release()
{
	if (ChPtr::NullCheck(emitter))return;

	AudioObject::Release();

	delete emitter;
	emitter = nullptr;
}

X3DAUDIO_EMITTER* X3DAudioObject::GetEmitter()
{
	if (ChPtr::NullCheck(emitter))return emitter;

	auto zDirection = mat.GetZAxisDirection();
	auto yDirection = mat.GetYAxisDirection();

	zDirection.Normalize();
	yDirection.Normalize();

	ChVec3 pos = mat.GetPosition();
	emitter->OrientFront = zDirection;
	emitter->OrientTop = yDirection;
	emitter->Position = pos;

	emitter->Velocity = pos - beforePos;

	return emitter;
}

void X3DAudioObject::Update()
{
	X3DAUDIO_DSP_SETTINGS dspSettings;

	dspSettings.SrcChannelCount = 1;
	dspSettings.DstChannelCount = manager->details->InputChannels;
	dspSettings.pMatrixCoefficients = manager->GetMatrix();

	auto&& emitter = GetEmitter();

	auto ePos = emitter->Position;
	emitter->Position.x *= BASE_LENGTH;
	emitter->Position.y *= BASE_LENGTH;
	emitter->Position.z *= BASE_LENGTH;
	auto lPos = manager->listener->Position;
	manager->listener->Position.x *= BASE_LENGTH;
	manager->listener->Position.y *= BASE_LENGTH;
	manager->listener->Position.z *= BASE_LENGTH;

	X3DAudioCalculate(manager->X3DInstance, manager->listener, emitter,
		X3DAUDIO_CALCULATE_MATRIX |
		X3DAUDIO_CALCULATE_DOPPLER |
		X3DAUDIO_CALCULATE_LPF_DIRECT |
		X3DAUDIO_CALCULATE_REVERB |
		X3DAUDIO_CALCULATE_EMITTER_ANGLE |
		X3DAUDIO_CALCULATE_DOPPLER,
		&dspSettings);

	emitter->Position = ePos;
	manager->listener->Position = lPos;

	voice->SetOutputMatrix(manager->audioMV, 1, manager->details->InputChannels, dspSettings.pMatrixCoefficients);
	voice->SetFrequencyRatio(dspSettings.DopplerFactor);

	voice->SetOutputMatrix(manager->audioMV, 1, 1, &dspSettings.ReverbLevel);

	XAUDIO2_FILTER_PARAMETERS FilterParameters = { LowPassFilter, 2.0f * sinf(X3DAUDIO_PI / 6.0f * dspSettings.LPFDirectCoefficient), 1.0f };
	voice->SetFilterParameters(&FilterParameters);
}

ChD3D::XAudio2Manager::~XAudio2Manager()
{
	Release();
}

size_t ChD3D::XAudio2Manager::GetAudioDataCount(const wchar_t* _key)
{
	auto&& data = audioDataMap.find(_key);
	if (data == audioDataMap.end())return 0;
	return data->second.size();
}

bool ChD3D::XAudio2Manager::ContainAudioData(const wchar_t* _key)
{
	return  audioDataMap.find(_key) != audioDataMap.end();
}

ChD3D::XAudio2Manager::MFObject* ChD3D::XAudio2Manager::CreateMFObjectPtr(const wchar_t* _key)
{
	auto&& mfObject = ChPtr::Make_S<MFObject>();

	if (!MFObjectInit(_key, *mfObject))
		return nullptr;

	mfObjectMap[_key] = mfObject;

	return mfObject.get();
}

bool ChD3D::XAudio2Manager::CreateFileData(const wchar_t* _fileName)
{
	if (ContainAudioData(_fileName))return true;

	if (!loadFlg)return false;


	std::vector<XAUDIO2_BUFFER*> fileDatas;

	auto&& mfObject = GetMFObject(_fileName);

	ChXAUDIO2_BUFFER* fileData = static_cast<ChXAUDIO2_BUFFER*>(LoadBuffers(mfObject));

	while (ChPtr::NotNullCheck(fileData))
	{
		fileDatas.push_back(fileData);

		fileData = static_cast<ChXAUDIO2_BUFFER*>(LoadBuffers(mfObject));
	}

	audioDataMap[_fileName] = fileDatas;
	return true;
}

XAUDIO2_BUFFER* ChD3D::XAudio2Manager::SetBuffer(BYTE* _data, unsigned long _maxStreamLen)
{
	auto fileData = new ChXAUDIO2_BUFFER();

	for (DWORD i = 0; i < _maxStreamLen; i++)
	{
		unsigned char data = _data[i];
		fileData->audioDataVector.push_back(data);
	}

	fileData->AudioBytes = _maxStreamLen;
	fileData->pAudioData = &fileData->audioDataVector[0];
	fileData->Flags = XAUDIO2_END_OF_STREAM;

	return fileData;
}

ChD3D::XAudio2Manager::MFObject* ChD3D::XAudio2Manager::GetMFObject(const wchar_t* _key)
{
	auto&& obj = mfObjectMap.find(_key);

	if (obj == mfObjectMap.end())return nullptr;
	return obj->second.get();
}

bool ChD3D::XAudio2Manager::ContainMFObject(const wchar_t* _key)
{
	return mfObjectMap.find(_key) != mfObjectMap.end();
}

void ChD3D::XAudio2Manager::SubmitSourceBuffer(IXAudio2SourceVoice* _voice, const wchar_t* _filename, size_t _num)
{
	if (ChPtr::NullCheck(_voice))return;
	if (ChPtr::NullCheck(_filename))return;
	auto&& audioData = audioDataMap.find(_filename);
	if (audioData == audioDataMap.end())return;
	if (audioData->second.size() <= _num)return;

	_voice->SubmitSourceBuffer(audioData->second[_num]);
}

void ChD3D::XAudio2Manager::AddAudios(AudioObject* _obj)
{
	audios.push_back(_obj);
}

void ChD3D::XAudio2Manager::RemoveAudios(AudioObject* _obj)
{
	auto&& thiss = std::find(audios.begin(), audios.end(), _obj);

	audios.erase(thiss);
}

void ChD3D::XAudio2Manager::UpdateAudios()
{
	for (auto&& audio = audios.begin(); audio != audios.end(); audio)
	{
		if (*audio == nullptr)
		{
			audio = audios.erase(audio);
			continue;
		}
		(*audio)->Update();

		audio++;
	}
}

float* ChD3D::XAudio2Manager::GetMatrix()
{
	return &matrix[0];
}

void ChD3D::XAudio2Manager::ResizeMatrix(size_t _num)
{
	matrix.resize(_num);
}

void ChD3D::XAudio2Manager::CRTRelease()
{
	for (auto&& aObject : audios)
	{
		aObject->Release();
	}

	for (auto&& waveFormat : mfObjectMap)
	{
		MFObjectRelease(*waveFormat.second);
	}

	for (auto&& audioDatas : audioDataMap)
	{
		for (auto&& audioData : audioDatas.second)
		{
			delete audioData;
		}
	}

	audioDataMap.clear();

	mfObjectMap.clear();

	audios.clear();

}

void XAudio2Manager::Init()
{
	if (*this)return;

	XAudio2Create(&audio, 0, XAUDIO2_DEFAULT_PROCESSOR);

	if (ChPtr::NullCheck(audio))
	{
		Release();
		return;
	}

	audio->CreateMasteringVoice(&audioMV);

	if (ChPtr::NullCheck(audioMV))
	{
		Release();
		return;
	}
	DWORD dwChannelMask;
	audioMV->GetChannelMask(&dwChannelMask);
	//X3DAudioInitialize(dwChannelMask, X3DAUDIO_SPEED_OF_SOUND, X3DInstance);
	X3DAudioInitialize(dwChannelMask, X3DAUDIO_SPEED_OF_SOUND * 0.01f, X3DInstance);

	details = new XAUDIO2_VOICE_DETAILS();

	audioMV->GetVoiceDetails(details);

	ResizeMatrix(details->InputChannels);

	listener = new X3DAUDIO_LISTENER();

	audio->CreateSubmixVoice(&subMixAudio, 1, 44100, 0, 0, 0, 0);
	sender = new XAUDIO2_SEND_DESCRIPTOR();
	sender->Flags = 0;
	sender->pOutputVoice = subMixAudio;
	sendList = new XAUDIO2_VOICE_SENDS();
	sendList->SendCount = 1;
	sendList->pSends = sender;

	SetInitFlg(true);

}

bool XAudio2Manager::MFObjectInit(const wchar_t* _key,MFObject& _target)
{
	return MFCreateSourceReaderFromURL(
		_key,
		nullptr,
		&_target.reader) == S_OK;
}

void XAudio2Manager::Release()
{

	if (!*this)return;

	LoadEnd();

	CRTRelease();

	if (ChPtr::NotNullCheck(listener)) { delete listener; listener = nullptr; }
	if (ChPtr::NotNullCheck(details)) { delete details; details = nullptr; }

	if (ChPtr::NotNullCheck(subMixAudio)) { subMixAudio->DestroyVoice(); subMixAudio = nullptr; }
	if (ChPtr::NotNullCheck(sender)) { delete sender; sender = nullptr; }
	if (ChPtr::NotNullCheck(sendList)) { delete sendList; sendList = nullptr; }

	if (ChPtr::NotNullCheck(audioMV)) { audioMV->DestroyVoice(); audioMV = nullptr; };
	if (ChPtr::NotNullCheck(audio)) { audio->Release(); audio = nullptr; };

	SetInitFlg(false);
}

void XAudio2Manager::MFObjectRelease(MFObject& _target)
{
	CoTaskMemFree(_target.waveFormat);

	_target.reader->Release();
}

void XAudio2Manager::LoadStart()
{
	if (loadFlg)return;

	MFStartup(MF_VERSION);

	(void)CoInitializeEx(nullptr, COINIT_MULTITHREADED);

	loadFlg = true;
}

void XAudio2Manager::LoadEnd()
{
	if (!loadFlg)return;

	MFShutdown();

	loadFlg = false;
}

void XAudio2Manager::LoadSoundBase(AudioObject& _object, const wchar_t* _fileName)
{
	if (ChPtr::NullCheck(&_object))return;

	if (!CreateMFObject(_fileName))return;
	if (!CreateFileData(_fileName))return;

	auto&& mfObject = GetMFObject(_fileName);

	_object.Init();

	audio->CreateSourceVoice(&_object.voice, mfObject->waveFormat, 0, 2.0f, 0, sendList);

	SubmitSourceBuffer(_object.voice, _fileName, 0);
	SubmitSourceBuffer(_object.voice, _fileName, 1);

	_object.SetFileName(_fileName);

	_object.SetInitFlg(true);

	_object.manager = this;

	AddAudios(&_object);
}

bool XAudio2Manager::CreateMFObject(const wchar_t* _fileName)
{
	if (ContainMFObject(_fileName))return true;

	if (!loadFlg)return false;

	auto mfObject = CreateMFObjectPtr(_fileName);

	IMFMediaType* mType = nullptr;
	MFCreateMediaType(&mType);

	mType->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
	mType->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_PCM);

	mfObject->reader->SetCurrentMediaType((MF_SOURCE_READER_FIRST_AUDIO_STREAM), 0, mType);

	mType->Release();

	mfObject->reader->GetCurrentMediaType((MF_SOURCE_READER_FIRST_AUDIO_STREAM), &mType);

	UINT32 size = 0;

	MFCreateWaveFormatExFromMFMediaType(mType, &mfObject->waveFormat, &size);

	mType->Release();

	return true;
}

XAUDIO2_BUFFER* ChD3D::XAudio2Manager::LoadBuffers(MFObject* _MFObj)
{
	DWORD streamFlg = 0;
	LONGLONG streamLen = 0;

	IMFSample* sample;

	_MFObj->reader->ReadSample(MF_SOURCE_READER_FIRST_AUDIO_STREAM, 0, nullptr, &streamFlg, &streamLen, &sample);

	if (ChPtr::NullCheck(sample))return nullptr;

	IMFMediaBuffer* mediaBuffer;

	sample->ConvertToContiguousBuffer(&mediaBuffer);

	BYTE* data;

	DWORD maxStreamLen;
	DWORD currentLen;

	mediaBuffer->GetMaxLength(&maxStreamLen);
	mediaBuffer->GetCurrentLength(&currentLen);

	mediaBuffer->Lock(&data, &maxStreamLen, &currentLen);

	auto&& fileData = SetBuffer(data,maxStreamLen);

	mediaBuffer->Unlock();

	mediaBuffer->Release();

	sample->Release();

	return fileData;
}

void XAudio2Manager::Update()
{
	
	auto zDirection = mat.GetZAxisDirection();
	auto yDirection = mat.GetYAxisDirection();

	zDirection.Normalize();
	yDirection.Normalize();

	ChVec3 pos = mat.GetPosition();

	listener->OrientFront = zDirection;
	listener->OrientTop = yDirection;
	listener->Position = pos;
	listener->Velocity = pos - beforePos;
	
	UpdateAudios();
	
}
