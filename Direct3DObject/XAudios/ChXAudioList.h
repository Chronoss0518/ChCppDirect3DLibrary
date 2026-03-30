#pragma once

struct IMFSourceReader;
struct tWAVEFORMATEX;

struct X3DAUDIO_LISTENER;
typedef unsigned char X3DAUDIO_HANDLE[20];

class AudioObject;
class X3DAudioObject;

namespace ChD3D
{

	class XAudioList :public ChCp::Initializer
	{
	public:

		friend AudioObject;
		friend X3DAudioObject;

	private:

		struct MFObject
		{
			IMFSourceReader* reader = nullptr;

			tWAVEFORMATEX* waveFormat = nullptr;
		};

		struct ChXAUDIO2_BUFFER :public XAUDIO2_BUFFER
		{
			std::vector<unsigned char> audioDataVector;
		};

		virtual ~XAudioList();

	public://Init And Release//

		void Init();

		inline void InitPosition(const ChVec3& _pos)
		{
			mat.Identity();
			mat.SetPosition(_pos);
			beforePos = mat.GetPosition();
		}

		inline void InitMatrix(const ChLMat& _mat)
		{
			mat = _mat;
			beforePos = mat.GetPosition();
		}

		virtual void Release();

	private:

		bool MFObjectInit(const wchar_t* _key, MFObject& _target);

		void CRTRelease();

		void MFObjectRelease(MFObject& _target);

	public://Set Functions//

		inline void SetMatrix(const ChLMat& _mat)
		{
			beforePos = mat.GetPosition();
			mat = _mat;
		}

		inline void SetPosition(const ChVec3& _pos)
		{
			beforePos = mat.GetPosition();
			mat.SetPosition(_pos);
		}

		inline void SetRotation(const ChQua& _dir)
		{
			mat.SetRotation(_dir);
		}

	public://Get Functions//

		inline ChVec3 GetPosition() { return mat.GetPosition(); }

	public://Load Functions//

		void LoadStart();

		void LoadEnd();

		void LoadSound(AudioObject& _object, const std::wstring& _str)
		{
			LoadSoundBase(_object, _str.c_str());
		}

	private:

		void LoadSoundBase(AudioObject& _object, const wchar_t* _str);

	public://Update Function//

		void Update();

	private:

		bool CreateMFObject(const wchar_t* _fileName);

		bool CreateFileData(const wchar_t* _fileName);

	private:

		XAUDIO2_BUFFER* LoadBuffers(MFObject* _MFObj);

		XAUDIO2_BUFFER* SetBuffer(BYTE* _data, unsigned long _maxStreamLen);

		bool ContainAudioData(const wchar_t* _key);

		size_t GetAudioDataCount(const wchar_t* _key);

		MFObject* CreateMFObjectPtr(const wchar_t* _key);

		bool ContainMFObject(const wchar_t* _key);

		MFObject* GetMFObject(const wchar_t* _key);

		void SubmitSourceBuffer(IXAudio2SourceVoice* _voice, const wchar_t* _filename, size_t _num);

		void AddAudios(AudioObject* _obj);

		void RemoveAudios(AudioObject* _obj);

		void UpdateAudios();

		float* GetMatrix();

		void ResizeMatrix(size_t _num);

	private:

		bool loadFlg = false;

		IXAudio2* audio = nullptr;
		IXAudio2MasteringVoice* audioMV = nullptr;
		IXAudio2SubmixVoice* subMixAudio = nullptr;
		XAUDIO2_SEND_DESCRIPTOR* sender = nullptr;
		XAUDIO2_VOICE_SENDS* sendList = nullptr;

		//3DAudioŠÖ˜A//
		X3DAUDIO_LISTENER* listener = nullptr;
		X3DAUDIO_HANDLE X3DInstance;
		XAUDIO2_VOICE_DETAILS* details = nullptr;

		ChLMat mat;
		ChVec3 beforePos;

		std::map<std::wstring, std::vector<XAUDIO2_BUFFER*>>audioDataMap;
		std::map<std::wstring, ChPtr::Shared<MFObject>>mfObjectMap;

		std::vector<AudioObject*>audios;
		std::vector<float>matrix;
	};

}