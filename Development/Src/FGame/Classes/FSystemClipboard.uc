/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSystemClipboard extends Object
	DLLBind(clipboard);

var private int Buffer[201];

/**
 * Get text from system clipboard
 */
dllimport private final function string GetTextFromClipboard();

/**
 * Set system clipboard text
 */
dllimport private final function SetClipboardText(int unicodeArray[201], int length);

function string GetText()
{
	return GetTextFromClipboard();
}

function SetText(string Text)
{
	local int Length;
	Length = Min(Len(Text),200);
	GenerateUnicodeArray(Text, Length);
	SetClipboardText(Buffer,Length);	
}

private function GenerateUnicodeArray(string Text, int Length)
{
	local int i;
	local string Char;

	for (i=0; i<Length; i++)
	{
		Char = Mid(Text,i,1);
		Buffer[i] = Asc(Char);
	}

	Buffer[Length] = 0; // Null character at the end of the string
}

DefaultProperties
{	
}
