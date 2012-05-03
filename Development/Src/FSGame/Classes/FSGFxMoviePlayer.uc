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
 Functions calling ActionScript
**********************************************************************************************/

function DataUpdated()
{
	ActionScriptVoid("_root.dataBuffer.dataUpdated");
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function GetData(string DataName)
{
	local GFxObject DataBuffer;
	local GFxObject DataArray;
	local array<string> Data;
	local FSPlayerController FSPC;

	local string DataItem;
	local int DataItemIndex;

	switch (DataName)
	{
	case "RedTeamPlayers":
		foreach GetPC().WorldInfo.AllControllers(class'FSPlayerController', FSPC)
			if (FSPC.PlayerReplicationInfo.Team.TeamIndex == 0)
				Data.AddItem(FSPC.PlayerReplicationInfo.PlayerName);
		break;
	case "BlueTeamPlayers":
		foreach GetPC().WorldInfo.AllControllers(class'FSPlayerController', FSPC)
			if (FSPC.PlayerReplicationInfo.Team.TeamIndex == 1)
				Data.AddItem(FSPC.PlayerReplicationInfo.PlayerName);
		break;
	}

	Data.AddItem("DataEnd");

	DataBuffer = GetVariableObject("_root.dataBuffer");

	DataArray = CreateArray();
	
	foreach Data(DataItem, DataItemIndex)
		DataArray.SetElementString(DataItemIndex, DataItem);

	DataBuffer.SetObject("data", DataArray);

	DataUpdated();
}

defaultproperties
{
	bDisplayMouseCursor=false
	bDisplayedMouseCursor=false
}
