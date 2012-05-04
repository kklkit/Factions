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
	Super.Start(StartPaused);

	if (bDisplayMouseCursor)
	{
		if (GetGameViewportClient().bDisplayHardwareMouseCursor)
			bDisplayedMouseCursor = false;
		else
		{
			GetGameViewportClient().bDisplayHardwareMouseCursor = true;
			bDisplayedMouseCursor = true;
		}
	}

	return true;
}

function OnClose()
{
	Super.OnClose();

	if (bDisplayedMouseCursor)
		GetGameViewportClient().bDisplayHardwareMouseCursor = false;
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

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function array<string> GetTeamPlayers(string Team)
{
	local array<string> Data;
	local FSPlayerController FSPC;
	local byte TeamIndex;

	TeamIndex = Team ~= "Red" ? 0 : 1;

	foreach GetPC().WorldInfo.AllControllers(class'FSPlayerController', FSPC)
		if (FSPC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
			Data.AddItem(FSPC.PlayerReplicationInfo.PlayerName);

	return Data;
}

defaultproperties
{
	bDisplayMouseCursor=false
	bDisplayedMouseCursor=false
}
