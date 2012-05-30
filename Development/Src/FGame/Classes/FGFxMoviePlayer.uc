/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxMoviePlayer extends GFxMoviePlayer;

var bool bDisplayMouseCursor;

var private bool bDisplayedMouseCursor;

event bool Start(optional bool StartPaused = False)
{
	Super.Start(StartPaused);

	if (bDisplayMouseCursor)
	{
		if (GetGameViewportClient().bDisplayHardwareMouseCursor)
		{
			bDisplayedMouseCursor = False;
		}
		else
		{
			GetGameViewportClient().SetHardwareMouseCursorVisibility(True);
			bDisplayedMouseCursor = True;
		}
	}

	return true;
}

event OnClose()
{
	if (bDisplayedMouseCursor)
		GetGameViewportClient().SetHardwareMouseCursorVisibility(False);

	Super.OnClose();
}

function FPawn GetPlayerPawn()
{
	local UDKPawn PlayerPawn;
	local UDKVehicle PlayerVehicle;
	local UDKWeaponPawn PlayerWeaponPawn;

	PlayerPawn = UDKPawn(GetPC().Pawn);

	// Return the pawn for driven vehicles
	if (PlayerPawn == None)
	{
		PlayerVehicle = UDKVehicle(GetPC().Pawn);

		if (PlayerVehicle == None)
		{
			PlayerWeaponPawn = UDKWeaponPawn(GetPC().Pawn);
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
