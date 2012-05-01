/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxMoviePlayer extends GFxMoviePlayer;

var bool bDisplayMouseCursor;
var FSPlayerController PC;

var private bool bDisplayedMouseCursor;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	PC = FSPlayerController(GetPC());
}

function bool Start(optional bool StartPaused)
{
	Super.Start(StartPaused);

	if (bDisplayMouseCursor)
	{
		if (GetGameViewportClient().bDisplayHardwareMouseCursor)
			bDisplayedMouseCursor = false;
		else
		{
			GetGameViewportClient().bDisplayHardwareMouseCursor = true;
			bDisplayedMouseCursor = true;
		}
	}

	return true;
}

function OnClose()
{
	Super.OnClose();

	if (bDisplayedMouseCursor)
		GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

defaultproperties
{
	bDisplayMouseCursor=false
	bDisplayedMouseCursor=false
}
