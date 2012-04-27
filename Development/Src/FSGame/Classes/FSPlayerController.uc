/**
 * Factions player controller.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

simulated state Commanding
{
	/**
	 * @extends
	 */
	event BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;

		super.BeginState(PreviousStateName);

		ViewLocation.X = Pawn.Location.X - 2048;
		ViewLocation.Y = Pawn.Location.Y;
		ViewLocation.Z = Pawn.Location.Z + 2048;

		SetLocation(ViewLocation);
		SetRotation(Rotator(Pawn.Location - ViewLocation));
	}

	/**
	 * @extends
	 */
	function PlayerMove(float DeltaTime)
	{
		if (Pawn == None)
		{
			GotoState('Dead');
		}
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
}