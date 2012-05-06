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
		if (PC.PlacingStructureIndex != 0)
			StatusText.SetText("Placing:" @ class'FSStructure'.static.GetStructureClass(PC.PlacingStructureIndex));
		else
			StatusText.SetText("No structure selected");
	}
	else
		StatusText = GetVariableObject("_root.statusText");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bAutoPlay=false
	bDisplayWithHudOff=false
	bDisplayMouseCursor=true
}
