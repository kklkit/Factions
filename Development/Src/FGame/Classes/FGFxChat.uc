/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxChat extends FGFxMoviePlayer;

/**
 * Displays the chat box.
 */
function OpenChat(name ChatChannel)
{
	GetPC().PlayerInput.ResetInput();

	FHUD(GetPC().myHUD).UpdateMoviePriorities(True);
	StartUsingChatInputBox(string(ChatChannel));
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

/**
 * Called when the player press enter when using the chatInputBox
 */
function SendChat(string ChatMessage, bool bTeamMessage)
{
	if (ChatMessage != "")
	{
		if (bTeamMessage)
			GetPC().TeamSay(ChatMessage);
		else
			GetPC().Say(ChatMessage);
	}

	FHUD(GetPC().myHUD).UpdateMoviePriorities(False);
	StopUsingChatInputBox();
}

/*********************************************************************************************
 Functions calling ActionScript
 
 These functions simply forwards the call with its parameters to Flash.
 
 Always check to make sure the movie is open before calling Flash. The game will crash if a
 function is called while the movie is closed.
**********************************************************************************************/

function StartUsingChatInputBox(string ChatChannel)
{
	if (bMovieIsOpen)
	{
		bCaptureInput = True;		
		ActionScriptVoid("_root.enableChatInputBox");
		bCaptureMouseInput = True;
		SetHardwareMouseCursorVisibility(True);
	}	
}

function StopUsingChatInputBox()
{
	bCaptureInput = False;		
	DisableChatInputBox();
	bCaptureMouseInput = False;
	SetHardwareMouseCursorVisibility(False);
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

function SetChatLogBoxText(string SetText)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.setChatInputBoxText");
}

function ChatLogBoxAddNewChatLine(string ChatLine, int PreferredColor)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.addNewChatLine");
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_chat'
	bDisplayWithHudOff=False
}
