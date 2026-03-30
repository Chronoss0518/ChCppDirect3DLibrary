#pragma once

#include"ChXAudioList.h"

namespace ChD3D
{

	class XAudio2Manager :public ChCp::Initializer
	{
	private:

		XAudio2Manager() {}

		virtual ~XAudio2Manager();

	public://Init And Release//

		inline void Init() { manager.Init(); }

		inline void InitPosition(const ChVec3& _pos){ manager.InitPosition(_pos); }

		inline void InitMatrix(const ChLMat& _mat){ manager.InitMatrix(_mat); }

		inline void Release() { manager.Release(); }

	public://Set Functions//

		inline void SetMatrix(const ChLMat& _mat) { manager.SetMatrix(_mat); }

		inline void SetPosition(const ChVec3& _pos) { manager.SetPosition(_pos); }

		inline void SetRotation(const ChQua& _dir) { manager.SetRotation(_dir); }

	public://Get Functions//

		inline ChVec3 GetPosition() { return manager.GetPosition(); }

	public://Load Functions//

		inline void LoadStart() { manager.LoadStart(); }

		inline void LoadEnd() { manager.LoadEnd(); }

		inline void LoadSound(AudioObject& _object, const std::wstring& _str) { manager.LoadSound(_object, _str); }

	public://Update Function//

		inline void Update() { manager.Update(); }

	private:

		XAudioList manager;

	public:

		static XAudio2Manager& GetIns()
		{
			static XAudio2Manager ins;
			return ins;
		}

	};

	inline XAudio2Manager& XAudioManager() { return XAudio2Manager::GetIns(); }
}