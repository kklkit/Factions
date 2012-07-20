/**
 * Interacts with chat input box and chatlog box.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxChat extends FGFxMoviePlayer;

/**
 * @extends
 */
function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	// Add Enter key to ignore list to avoid being captured as a chat input
	AddFocusIgnoreKey('Enter');
}

function StartUsingChatInputBox()
{
	if (bMovieIsOpen)
	{
		bCaptureInput = True;		
		ActionScriptVoid("_root.enableChatInputBox");
	}	
}

function StopUsingChatInputBox()
{
	bCaptureInput = False;		
	DisableChatInputBox();
}

function DisableChatInputBox()
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.disableChatInputBox");
}

function string GetChatInputBoxText()
{
	if (bMovieIsOpen)
		return ActionScriptString("_root.getChatInputBoxText");
	else
		return "ERROR: GFxMoviePlayer is not initialized";
}

function SetChatLogBoxText(string setText)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.setChatInputBoxText");
}


function ChatLogBoxAddNewChatLine(string chatLine, int preferedColor)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.addNewChatLine");
}

DefaultProperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_chat'
	bDisplayWithHudOff=False
}
