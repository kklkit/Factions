/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends FSGFxMoviePlayer;

var GFxObject StatusText;

function TickHUD()
{
	local FSPlayerController PC;

	if (!bMovieIsOpen)
		return;

	PC = FSPlayerController(GetPC());

	if (StatusText == None)
		StatusText = GetVariableObject("_root.statusText");

	if (StatusText != None)
	{
		if (PC.PlacingStructureClass != None)
			StatusText.SetText("Placing:" @ PC.PlacingStructureClass);
		else
			StatusText.SetText("No structure selected");
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bDisplayWithHudOff=False
	bDisplayMouseCursor=True
}
