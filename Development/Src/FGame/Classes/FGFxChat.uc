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
	//AddFocusIgnoreKey('Enter');
}


/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

/**
 * Called when the player press enter when using the chatInputBox
 */
function SendChat()
{
	FPlayerController(GetPC()).SendChat();	
}


/*********************************************************************************************
 Functions calling ActionScript
 
 These functions simply forwards the call with its parameters to Flash.
 
 Always check to make sure the movie is open before calling Flash. The game will crash if a
 function is called while the movie is closed.
**********************************************************************************************/

function StartUsingChatInputBox(bool bTeamChat)
{
	if (bMovieIsOpen)
	{
		bCaptureInput = True;		
		ActionScriptVoid("_root.enableChatInputBox");
		bCaptureMouseInput = True;
		bDisplayMouseCursor = True;
	}	
}

function StopUsingChatInputBox()
{
	bCaptureInput = False;		
	DisableChatInputBox();
	bCaptureMouseInput = False;
	bDisplayMouseCursor = False;
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
