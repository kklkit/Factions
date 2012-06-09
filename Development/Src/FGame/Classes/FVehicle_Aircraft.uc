/**
 * Base class for aircraft.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle_Aircraft extends FVehicle;

defaultproperties
{
	Begin Object Class=UDKVehicleSimChopper Name=SimObject
	End Object
	SimObj=SimObject

	bHomingTarget=True
	bNoZDampingInAir=False
	bCanStrafe=True
	bCanFly=True
	bTurnInPlace=True
	bFollowLookDir=True
	bEjectPassengersWhenFlipped=False
	bJostleWhileDriving=True
	bFloatWhenDriven=True
}
