/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle extends UDKVehicle
	placeable
	abstract;

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Name=SVehicleMesh
		LightEnvironment=MyLightEnvironment
	End Object
}
