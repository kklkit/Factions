/**
 * Factions player controller.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

var Vector CommanderViewLocation;
var Rotator CommanderViewRotation;

simulated state Commanding
{
	/**
	 * @extends
	 */
	event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		CommanderViewLocation.X = Pawn.Location.X - 2048;
		CommanderViewLocation.Y = Pawn.Location.Y;
		CommanderViewLocation.Z = Pawn.Location.Z + 2048;

		CommanderViewRotation = Rotator(Pawn.Location - CommanderViewLocation);
	}

	/**
	 * Commander view point.
	 * 
	 * @extends
	 */
	simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		out_Location = CommanderViewLocation;
		out_Rotation = CommanderViewRotation;
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