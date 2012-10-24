class FGFxMoviePlayer extends GFxMoviePlayer;

// DLL bind class for accessing system's clipboard
var FSystemClipboard SystemClipboard;

// If true, display the mouse cursor when this movie is open.
var bool bDisplayMouseCursorOnStart;

// If true, this movie is the one that displayed the mouse cursor. Other movie players should not attempt to display the mouse cursor again.
var private bool bDisplayedMouseCursor;


/**
 * @extends
 */
event bool Start(optional bool StartPaused = False)
{
	Super.Start(StartPaused);

	if (bDisplayMouseCursorOnStart)
		SetHardwareMouseCursorVisibility(True);

	return True;
}

/**
 * @extends
 */
event OnClose()
{
	SetHardwareMouseCursorVisibility(False);

	Super.OnClose();
}

/**
 * @extends
 */
function SetPriority(byte NewPriority)
{
	Super.SetPriority(NewPriority);

	if (FHUD(GetPC().myHUD) != None)
		FHUD(GetPC().myHUD).UpdateHardwareMouseCursorVisibility();
}

/**
 * Shows or hides the mouse cursor.
 */
function SetHardwareMouseCursorVisibility(bool bIsVisible)
{
	local FHUD myHUD;

	myHUD = FHUD(GetPC().myHUD);

	if (myHUD == None)
		return;

	if (bIsVisible)
	{
		// If the mouse cursor is already displayed.
		if (myHUD.bIsDisplayingMouseCursor)
		{
			// Set that this movie player didn't set the mouse cursor.
			bDisplayedMouseCursor = False;
		}
		else
		{
			// Display the mouse cursor.
			myHUD.bIsDisplayingMouseCursor = True;
			bDisplayedMouseCursor = True;
		}

		myHUD.UpdateHardwareMouseCursorVisibility();
	}
	else
	{
		if (bDisplayedMouseCursor)
		{
			bDisplayedMouseCursor = False;
			myHUD.bIsDisplayingMouseCursor = False;
		}

		myHUD.bUpdateMouseCursorOnNextTick = True;
	}
}

/**
 * Returns the actual player pawn (the infantry pawn).
 * 
 * Used the get the player when inside a vehicle.
 */
function FPawn GetPlayerPawn()
{
	// UDK classes are used since game-specific classes aren't required at this point.
	local UDKPawn PlayerPawn;
	local UDKVehicle PlayerVehicle;
	local UDKWeaponPawn PlayerWeaponPawn;

	// The player's pawn is the player controller's pawn if not in a vehicle.
	PlayerPawn = UDKPawn(GetPC().Pawn);

	// Get the pawn when inside a vehicle.
	if (PlayerPawn == None)
	{
		PlayerVehicle = UDKVehicle(GetPC().Pawn);

		// If the player is not driving a vehicle.
		if (PlayerVehicle == None)
		{
			PlayerWeaponPawn = UDKWeaponPawn(GetPC().Pawn);

			// Get the pawn when inside a vehicle weapon.
			if (PlayerWeaponPawn != None)
			{
				PlayerVehicle = PlayerWeaponPawn.MyVehicle;
				PlayerPawn = UDKPawn(PlayerWeaponPawn.Driver);
			}
		}
		else
		{
			PlayerPawn = FPawn(PlayerVehicle.Driver);
		}

		if (PlayerVehicle == None)
			return None;
	}

	return FPawn(PlayerPawn);
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

/**
 * Called when the GFx needs to get text from system clipboard
 */
function GFxObject RetriveSystemClipboardText()
{
	local GFxObject Result;
	local string RetrivedText;
	local ASValue asval;

	RetrivedText = SystemClipboard.GetText();
	Result = CreateObject("Object");

	asval.Type = AS_String;
	asval.s = RetrivedText;
	
	Result.Set("retrivedText",asval);

	return Result;	
}

function SetSystemClipboardText(string Text)
{
	SystemClipboard.SetText(Text);
}

defaultproperties
{
	Begin Object Class=FSystemClipboard Name=SCB		
	End Object
	SystemClipboard=SCB

	bDisplayMouseCursorOnStart=False
	bDisplayedMouseCursor=False
}
