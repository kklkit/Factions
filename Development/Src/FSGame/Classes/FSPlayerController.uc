/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

var byte CommanderMoveSpeed;
var bool bPlacingStructure;
var byte PlacingStructureIndex;

simulated state Commanding
{
	simulated function BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;

		ViewLocation.X = Pawn.Location.X - 2048;
		ViewLocation.Y = Pawn.Location.Y;
		ViewLocation.Z = Pawn.Location.Z + 2048;

		SetLocation(ViewLocation);
		SetRotation(Rotator(Pawn.Location - ViewLocation));

		FSHUD(myHUD).GFxCommanderHUD.Start();
	}

	simulated function EndState(name NextStateName)
	{
		FSHUD(myHUD).GFxCommanderHUD.Close(false);
	}

	simulated function GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		out_Location = Location;
		out_Rotation = Rotation;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector L;

		if (Pawn == None)
			GotoState('Dead');
		else
		{
			L = Location;

			if (PlayerInput.aForward > 0)
				L.X += CommanderMoveSpeed;
			else if (PlayerInput.aForward < 0)
				L.X -= CommanderMoveSpeed;

			if (PlayerInput.aStrafe > 0)
				L.Y += CommanderMoveSpeed;
			else if (PlayerInput.aStrafe < 0)
				L.Y -= CommanderMoveSpeed;

			SetLocation(L);
		}
	}

	exec function StartFire(optional byte FireModeNum)
	{
		FSHUD(myHUD).BeginDragging();
		PlaceStructure();
	}

	exec function StopFire(optional byte FireModeNum)
	{
		FSHUD(myHUD).EndDragging();
	}

	exec function ToggleCommandView()
	{
		GotoState('PlayerWalking');
	}

	exec function SelectStructure(byte StructureIndex)
	{
		PlacingStructureIndex = StructureIndex;
	}

	exec function PlaceStructure()
	{
		if (PlacingStructureIndex != 0)
			bPlacingStructure = true;
	}
}

reliable server function RequestVehicle()
{
	local FSStruct_VehicleFactory VF;

	VF = FSStruct_VehicleFactory(Pawn.Base);

	if (VF != None)
		VF.BuildVehicle(FSPawn(Pawn));
}

exec function BuildVehicle()
{
	RequestVehicle();
}

exec function ToggleCommandView()
{
	GotoState('Commanding');
}

defaultproperties
{
	InputClass=class'FSGame.FSPlayerInput'
	bPlacingStructure=false
	PlacingStructureIndex=0
	CommanderMoveSpeed=10
}