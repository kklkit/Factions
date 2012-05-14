/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends FSGFxMoviePlayer;

var GFxObject StatusText;

function TickHUD()
{
	if (!bMovieIsOpen)
		return;

	// Update status text
	if (StatusText != None)
	{
		if (FSPlayerController(GetPC()).PlacingStructureIndex != 0)
			StatusText.SetText("Placing:" @ class'FSStructure'.static.GetStructureClass(FSPlayerController(GetPC()).PlacingStructureIndex));
		else
			StatusText.SetText("No structure selected");
	}
	else
		StatusText = GetVariableObject("_root.statusText");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bDisplayWithHudOff=False
	bDisplayMouseCursor=True
}
