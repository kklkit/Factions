/**
 * Factions player controller.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

const MapViewRotation=rot(-16384,-16384,0);

var bool bViewingMap;

/**
 * Override to display the full-screen map if it is open.
 * 
 * @extends
 */
simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
{
	local Vector V;

	if (bViewingMap)
	{
		V.Z = FSMapInfo(WorldInfo.GetMapInfo()).MapRadius;
		out_Location = V;
		out_Rotation = MapViewRotation;
	} else {
		super.GetPlayerViewPoint(out_Location, out_Rotation);
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
		VP.BuildVehicle();
}

/**
 * Requests to build a vehicle.
 */
exec function BuildVehicle()
{
	RequestVehicle();
}

/**
 * Toggles opening and closing the full-screen map.
 */
exec function ToggleViewMap()
{
	bViewingMap = !bViewingMap;
	if (bViewingMap)
		SetFOV(90.0);
	else
		SetFOV(DefaultFOV);
}

defaultproperties
{
	InputClass=class'FSGame.FSPlayerInput'
	bViewingMap=false
}