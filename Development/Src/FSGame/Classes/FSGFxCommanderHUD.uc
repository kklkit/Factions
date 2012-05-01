/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends GFxMoviePlayer;

var GFxObject StatusText;

function TickHUD()
{
	local FSPlayerController PC;

	PC = FSPlayerController(GetPC());

	// Update status text
	if (StatusText != None)
	{
		if (PC.PlacingStructureIndex != 0)
			StatusText.SetText("Placing:" @ class'FSStructure'.static.GetStructureClass(PC.PlacingStructureIndex));
		else
			StatusText.SetText("No structure selected");
	}
	else
		StatusText = GetVariableObject("_root.statusText");
}

function bool Start(optional bool StartPaused)
{
	Super.Start(StartPaused);

	GetGameViewportClient().bDisplayHardwareMouseCursor = true;

	return true;
}

function OnClose()
{
	Super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bAutoPlay=false
}
