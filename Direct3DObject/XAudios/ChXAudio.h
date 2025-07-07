#ifndef Ch_D3DOBJ_XAudio2_h
#define Ch_D3DOBJ_XAudio2_h


#include<xaudio2.h>

struct IMFSourceReader;

struct X3DAUDIO_EMITTER;

struct IXAudio2;
struct IXAudio2SourceVoice;
struct IXAudio2MasteringVoice;
struct IXAudio2SubmixVoice;

struct XAUDIO2_SEND_DESCRIPTOR;
struct XAUDIO2_VOICE_SENDS;

struct X3DAUDIO_LISTENER;
typedef unsigned char X3DAUDIO_HANDLE[20];
typedef struct tWAVEFORMATEX WAVEFORMATEX;
struct XAUDIO2_VOICE_DETAILS;

namespace ChD3D
{
	class XAudio2Manager;

	class AudioObject :public ChCp::Initializer
	{
	public:

		friend XAudio2Manager;

	public:

		virtual ~AudioObject();

	public://Init And Release//

		virtual void Release();

	public://Set Functions//

		void SetLoopFlg(const bool _Flg) { loopFlg = _Flg; }

		void SetLoopStartPos(const size_t _pos) { loopStartPos = _pos; }

		void SetLoopEndPos(const size_t _pos) { loopEndPos = _pos; }

		void SetPlayTime(const size_t _Time) { nowPos = _Time; }

		void SetVolume(const float _Volume);

		void SetFileName(const wchar_t* _fileName);

	public://Get Functions//

		size_t GetLoopStartPos() { return loopStartPos; }

		size_t GetLoopEndPos() { return loopEndPos; }

		size_t GetPlayTime() { return nowPos; }

		float GetVolume();

		const wchar_t* GetFileName();

	public:

		virtual void Update();

	public:

		void Play();

		void Pause();

		void Stop();

	protected:

		virtual void Init() { Release(); }

		IXAudio2SourceVoice* voice = nullptr;
		bool loopFlg = false;
		size_t nowPos = 1;
		size_t loopStartPos = 0;
		size_t loopEndPos = -1;

		std::wstring fileName = L"";
		XAudio2Manager* manager = nullptr;

	};

	class X3DAudioObject :public AudioObject
	{
	public:

		friend XAudio2Manager;

	public:

		virtual ~X3DAudioObject()
		{
			Release();
		}

	public :

		void Init()override;

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

		void Release()override;

	public:

		inline void SetPosition(const ChVec3& _pos) 
		{
			beforePos = mat.GetPosition();
			mat.SetPosition(_pos); 
		}

		inline void SetRotation(const ChQua& _rot)
		{
			mat.SetRotation(_rot);
		}

		inline void SetMatrix(const ChLMat& _mat)
		{
			beforePos = mat.GetPosition();
			mat = _mat;
		}

	public:

		X3DAUDIO_EMITTER* GetEmitter();

		inline ChVec3 GetPosition() { return mat.GetPosition(); }

	public:

		void Update()override;

	private:

		X3DAUDIO_EMITTER* emitter = nullptr;
		ChLMat mat;
		ChVec3 beforePos;
	};

	class XAudio2Manager:public ChCp::Initializer
	{
	public:

		friend AudioObject;
		friend X3DAudioObject;

	private:

		struct MFObject
		{
			IMFSourceReader* reader = nullptr;

			WAVEFORMATEX* waveFormat = nullptr;
		};

		struct ChXAUDIO2_BUFFER :public XAUDIO2_BUFFER
		{
			std::vector<unsigned char> audioDataVector;
		};

	private:

		XAudio2Manager(){}

		virtual ~XAudio2Manager();

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

		void SubmitSourceBuffer(IXAudio2SourceVoice* _voice,const wchar_t* _filename, size_t _num);

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
	public:

		static XAudio2Manager& GetIns()
		{
			static XAudio2Manager ins;
			return ins;
		}

	};

	inline XAudio2Manager& XAudioManager() { return XAudio2Manager::GetIns(); }
}

#endif