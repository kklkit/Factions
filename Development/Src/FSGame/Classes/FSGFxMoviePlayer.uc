/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxMoviePlayer extends GFxMoviePlayer;

var bool bDisplayMouseCursor;

var private bool bDisplayedMouseCursor;

function bool Start(optional bool StartPaused = False)
{
	local bool Result;

	Result = Super.Start(StartPaused);

	if (bDisplayMouseCursor)
	{
		if (GetGameViewportClient().bDisplayHardwareMouseCursor)
			bDisplayedMouseCursor = False;
		else
		{
			GetGameViewportClient().SetHardwareMouseCursorVisibility(True);
			bDisplayedMouseCursor = True;
		}
	}

	return Result;
}

function OnClose()
{
	if (bDisplayedMouseCursor)
		GetGameViewportClient().SetHardwareMouseCursorVisibility(False);
}

function FSPawn GetPlayerPawn()
{
	local FSPawn FSP;
	local UDKVehicle FSV; //@todo change to FSVehicle
	local UDKWeaponPawn FWP; //@todo change to FSWeaponPawn

	FSP = FSPawn(GetPC().Pawn);

	// Set the pawn if driving a vehicle or mounted weapon
	if (FSP == None)
	{
		FSV = UDKVehicle(GetPC().Pawn);

		if (FSV == None)
		{
			FWP = UDKWeaponPawn(GetPC().Pawn);
			if (FWP != None)
			{
				FSV = FWP.MyVehicle;
				FSP = FSPawn(FWP.Driver);
			}
		}
		else
			FSP = FSPawn(FSV.Driver);

		if (FSV == None)
			return None;
	}

	return FSP;
}

defaultproperties
{
	bDisplayMouseCursor=False
	bDisplayedMouseCursor=False
}
