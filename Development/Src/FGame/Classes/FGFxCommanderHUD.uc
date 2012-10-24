class FGFxCommanderHUD extends FGFxMoviePlayer;

// Shown at the top of the screen to show the current action (e.g. what building class is selected for placement)
var GFxObject StatusText;

/**
 * @extends
 */
function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	SetPriority(40);
}

/**
 * Updates the interface elements in Flash.
 */
function TickHUD()
{
	local FPlayerController PlayerController;

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;

	// Get the owning player controller.
	PlayerController = FPlayerController(GetPC());

	// Set the status text object if it doesn't exist.
	if (StatusText == None)
		StatusText = GetVariableObject("_root.statusText");

	if (StatusText != None)
	{
		// Display the name of the structure being placed.
		if (PlayerController.PlacingStructure != None)
			StatusText.SetText("Placing:" @ PlayerController.PlacingStructure.GetHumanReadableName());
		else
			StatusText.SetText("No structure selected");
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_commander_hud'
	bDisplayWithHudOff=False
	bDisplayMouseCursorOnStart=True
}
