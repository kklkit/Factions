#include <string>
#include <Windows.h>

using namespace std;

extern "C"
{
	wchar_t* result = NULL;
	__declspec(dllexport) wchar_t* GetTextFromClipboard()
	{
		HANDLE clip;
		int bDataAvailable = 0;
		
		if (result != NULL)
		{
			delete [] result;
			result = NULL;
		}

		if (OpenClipboard(NULL)) {
			bDataAvailable = IsClipboardFormatAvailable(CF_UNICODETEXT);
			if (bDataAvailable)
				clip = GetClipboardData(CF_UNICODETEXT);
			CloseClipboard();
		}
						
		if (bDataAvailable)	
		{
			wchar_t* src = (wchar_t*)GlobalLock(clip);
			result = new wchar_t[wcslen(src)+1];
			wcscpy(result,src);
			GlobalUnlock(clip);
		}
		else
			result = L"";		
		
		/* Conversion from ANSI to Unicode (Now Obselete)
			// src = (char*)clip;		
			// dest = new wchar_t[1024];				
			// swprintf(dest,1024, L"%hs", src);
		*/
		
		return result;

		// Note: We do not need to free the memory of the HANDLE returned by the GetClipboardData function,
		//		 it is monitored by the Clipboard and we are not responsible for doing anything about it.
		// Note: As soon as the HANDLE returns to UDK, UDK will copy the data immediately. 
		//		 The HANDLE is not designed for long term uses as stated by MS. ALWAYS Copy data immedately.
   }

	__declspec(dllexport) void SetClipboardText(int* unicodeArray, int length)
	{
		
		if(OpenClipboard(NULL))
		{
			wchar_t* text;
			text = new wchar_t[length+1];

			for (int i=0; i<=length; i++)
				text[i] = unicodeArray[i];		


			HGLOBAL clipbuffer;
			wchar_t* buffer;
			EmptyClipboard();
			clipbuffer = GlobalAlloc(GMEM_DDESHARE, wcslen(text)*2+2);
			buffer = (wchar_t*)GlobalLock(clipbuffer);
			wcscpy(buffer, text);
			GlobalUnlock(clipbuffer);
			SetClipboardData(CF_UNICODETEXT,clipbuffer);
			CloseClipboard();
			delete [] text;		
		}
	}
}
