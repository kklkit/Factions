/**
 * Factions player controller.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends PlayerController;

const MapViewRotation=rot(-16384,-16384,0);

var bool InCommanderView;

var bool bViewingMap;

state CommanderView extends PlayerWalking
{

}

exec function ToggleCommanderView2()
{
	InCommanderView = !InCommanderView;
	
	if( InCommanderView )
		GotoState('CommanderView');
	else
		GotoState('PlayerWalking');
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

/**
 * Override to display the full-screen map if it is open.
 * 
 * @extends
 */
simulated function GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
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

defaultproperties
{
	InputClass=class'FSGame.FSPlayerInput'
	InCommanderView=false
	bViewingMap=false
}