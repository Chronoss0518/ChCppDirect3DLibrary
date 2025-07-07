#ifndef Ch_D3DOBJ_WICBitmap_h
#define Ch_D3DOBJ_WICBitmap_h

struct IWICImagingFactory;
struct IWICBitmap;

namespace ChD3D
{
	class WICBitmapCreator;

	class WICBitmapObject
	{
	public:

		friend WICBitmapCreator;

	public:

		void Release();

	public:

		IWICBitmap* const GetBitmap() const { return bitmap; }

	private:

		IWICBitmap* bitmap = nullptr;
	};

	class WICBitmapCreator
	{
	public:

		friend WICBitmapObject;

	public:

		virtual ~WICBitmapCreator();

	public:

		void Init();

		void Release();

	public:

		WICBitmapObject CreateBitmapObject(unsigned long _width, unsigned long _height);

	private:

		IWICBitmap* GetBitmap(size_t _num);

		size_t GetBitmapCount();

		void AddBitmap(IWICBitmap*);

		void ClearBitmapList();

	public:

		static WICBitmapCreator& GetIns()
		{
			static WICBitmapCreator ins;
			return ins;
		}

	private:

		IWICImagingFactory* factory = nullptr;

		std::vector<IWICBitmap*>bitmapList;
	};

	inline WICBitmapCreator& WICBitmapCreatorObj()
	{
		return WICBitmapCreator::GetIns();
	}

}

#endif