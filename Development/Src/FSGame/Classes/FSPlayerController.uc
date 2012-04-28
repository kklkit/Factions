/**
 * Factions player controller.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

var bool bPlacingStructure;
var byte PlacingStructureType;

simulated state Commanding
{
	simulated event BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;

		ViewLocation.X = Pawn.Location.X - 2048;
		ViewLocation.Y = Pawn.Location.Y;
		ViewLocation.Z = Pawn.Location.Z + 2048;

		SetLocation(ViewLocation);
		SetRotation(Rotator(Pawn.Location - ViewLocation));

		FSHUD(myHUD).GFxCommanderHUD.Start();

		super.BeginState(PreviousStateName);
	}

	simulated event EndState(name NextStateName)
	{
		FSHUD(myHUD).GFxCommanderHUD.Close(false);

		super.EndState(NextStateName);
	}

	/**
	 * Commander view point.
	 * 
	 * @extends
	 */
	simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		out_Location = Location;
		out_Rotation = Rotation;
	}

	/**
	 * @extends
	 */
	function PlayerMove(float DeltaTime)
	{
		local Vector L;

		if (Pawn == None)
		{
			GotoState('Dead');
		}
		else
		{
			L = Location;

			if (PlayerInput.aForward > 0)
			{
				L.X += 10;
			}
			else if (PlayerInput.aForward < 0)
			{
				L.X -= 10;
			}

			if (PlayerInput.aStrafe > 0)
			{
				L.Y += 10;
			}
			else if (PlayerInput.aStrafe < 0)
			{
				L.Y -= 10;
			}

			SetLocation(L);
		}
	}

	/**
	 * @extends
	 */
	exec function StartFire(optional byte FireModeNum)
	{
		FSHUD(myHUD).BeginDragging();
	}

	/**
	 * @extends
	 */
	exec function StopFire(optional byte FireModeNum)
	{
		FSHUD(myHUD).EndDragging();
		PlaceStructure();
	}

	/**
	 * Exits the command view.
	 */
	exec function ToggleCommandView()
	{
		GotoState('PlayerWalking');
	}
}

/**
 * Builds the requested vehicle.
 */
reliable server function RequestVehicle()
{
	local FSVehiclePad VP;

	foreach DynamicActors(class'FSVehiclePad', VP, class'FSActorInterface')
		break;

	if (VP != None)
		VP.BuildVehicle(FSPawn(Pawn));
}

/**
 * Requests to build a vehicle.
 */
exec function BuildVehicle()
{
	RequestVehicle();
}

exec function PlaceStructure()
{
	bPlacingStructure = true;
}


/**
 * Enters the command view.
 */
exec function ToggleCommandView()
{
	GotoState('Commanding');
}

defaultproperties
{
	InputClass=class'FSGame.FSPlayerInput'
	bPlacingStructure=false
	PlacingStructureType=0
}