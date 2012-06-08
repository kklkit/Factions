/**
 * Base class for all game GUIs.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxMoviePlayer extends GFxMoviePlayer;

// If true, display the mouse cursor when this movie is open.
var bool bDisplayMouseCursor;

// If true, this movie is the one that displayed the mouse cursor. Other movie players should not attempt to display the mouse cursor again.
var private bool bDisplayedMouseCursor;

/**
 * @extends
 */
event bool Start(optional bool StartPaused = False)
{
	Super.Start(StartPaused);

	// If this movie player should display the mouse cursor.
	if (bDisplayMouseCursor)
	{
		// If the mouse cursor is already displayed.
		if (GetGameViewportClient().bDisplayHardwareMouseCursor)
		{
			// Set that this movie player didn't set the mouse cursor.
			bDisplayedMouseCursor = False;
		}
		else
		{
			// Display the mouse cursor.
			GetGameViewportClient().SetHardwareMouseCursorVisibility(True);
			bDisplayedMouseCursor = True;
		}
	}

	return true;
}

/**
 * @extends
 */
event OnClose()
{
	// Hide the mouse cursor if this movie clip displayed it.
	if (bDisplayedMouseCursor)
	{
		bDisplayedMouseCursor = False;
		GetGameViewportClient().SetHardwareMouseCursorVisibility(False);
	}

	Super.OnClose();
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

defaultproperties
{
	bDisplayMouseCursor=False
	bDisplayedMouseCursor=False
}
