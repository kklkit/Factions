/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxMoviePlayer extends GFxMoviePlayer;

var bool bDisplayMouseCursor;
var FSPlayerController PC;

var private bool bDisplayedMouseCursor;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	PC = FSPlayerController(GetPC());
}

function bool Start(optional bool StartPaused)
{
	local bool Result;

	Result = Super.Start(StartPaused);

	if (bDisplayMouseCursor)
	{
		if (GetGameViewportClient().bDisplayHardwareMouseCursor)
			bDisplayedMouseCursor = false;
		else
		{
			GetGameViewportClient().SetHardwareMouseCursorVisibility(true);
			bDisplayedMouseCursor = true;
		}
	}

	return Result;
}

function OnClose()
{
	Super.OnClose();

	if (bDisplayedMouseCursor)
		GetGameViewportClient().SetHardwareMouseCursorVisibility(false);
}

function FSPawn GetPlayerPawn()
{
	local FSPawn FSP;
	local UDKVehicle FSV; //@todo change to FSVehicle
	local UDKWeaponPawn FWP; //@todo change to FSWeaponPawn

	FSP = FSPawn(PC.Pawn);

	// Set the pawn if driving a vehicle or mounted weapon
	if (FSP == None)
	{
		FSV = UDKVehicle(PC.Pawn);

		if (FSV == None)
		{
			FWP = UDKWeaponPawn(PC.Pawn);
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
	bDisplayMouseCursor=false
	bDisplayedMouseCursor=false
}
