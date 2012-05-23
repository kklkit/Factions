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
	local FPawn FP;
	local UDKVehicle FV; //@todo change to FVehicle
	local UDKWeaponPawn FWP; //@todo change to FWeaponPawn

	FP = FPawn(GetPC().Pawn);

	// Set the pawn if driving a vehicle or mounted weapon
	if (FP == None)
	{
		FV = UDKVehicle(GetPC().Pawn);

		if (FV == None)
		{
			FWP = UDKWeaponPawn(GetPC().Pawn);
			if (FWP != None)
			{
				FV = FWP.MyVehicle;
				FP = FPawn(FWP.Driver);
			}
		}
		else
		{
			FP = FPawn(FV.Driver);
		}

		if (FV == None)
			return None;
	}

	return FP;
}

defaultproperties
{
	bDisplayMouseCursor=False
	bDisplayedMouseCursor=False
}
