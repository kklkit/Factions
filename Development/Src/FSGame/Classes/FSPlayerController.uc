/**
 * Factions player controller.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

const MapViewRotation=rot(-16384,-16384,0);

var bool bViewingMap;

simulated state Commanding
{
	/**
	 * Commander view point.
	 */
	simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		out_Location = vect(0, 0, 0);
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
	bViewingMap=false
}