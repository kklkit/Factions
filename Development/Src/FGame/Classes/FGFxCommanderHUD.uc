/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxCommanderHUD extends FGFxMoviePlayer;

var GFxObject StatusText;

function TickHUD()
{
	local FPlayerController PC;

	if (!bMovieIsOpen)
		return;

	PC = FPlayerController(GetPC());

	if (StatusText == None)
		StatusText = GetVariableObject("_root.statusText");

	if (StatusText != None)
	{
		if (PC.PlacingStructureInfo.Name != '')
			StatusText.SetText("Placing:" @ PC.PlacingStructureInfo.Name);
		else
			StatusText.SetText("No structure selected");
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_commander_hud'
	bDisplayWithHudOff=False
	bDisplayMouseCursor=True
}
