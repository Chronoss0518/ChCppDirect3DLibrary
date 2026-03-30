#ifndef Ch_D3DOBJ_XAudio2_h
#define Ch_D3DOBJ_XAudio2_h


#include<xaudio2.h>

struct IXAudio2SourceVoice;

struct X3DAUDIO_EMITTER;

namespace ChD3D
{
	class XAudioList;

	class AudioObject :public ChCp::Initializer
	{
	public:

		friend XAudioList;

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
		XAudioList* manager = nullptr;

	};

	class X3DAudioObject :public AudioObject
	{
	public:

		friend XAudioList;

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

}

#endif