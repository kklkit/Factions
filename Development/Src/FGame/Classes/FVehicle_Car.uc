/**
 * Base class for 4-wheeled vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle_Car extends FVehicle;

defaultproperties
{
	Begin Object Class=UDKVehicleSimCar Name=SimObject
		bClampedFrictionModel=True
	End Object
	SimObj=SimObject

	Begin Object Class=UDKVehicleWheel Name=FLWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire_Cont"
		SteerFactor=1.0
		bPoweredWheel=True
	End Object
	Wheels(0)=FLWheel

	Begin Object Class=UDKVehicleWheel Name=FRWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire_Cont"
		SteerFactor=1.0
		bPoweredWheel=True
	End Object
	Wheels(1)=FRWheel

	Begin Object Class=UDKVehicleWheel Name=BLWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire_Cont"
		bPoweredWheel=True
	End Object
	Wheels(2)=BLWheel

	Begin Object Class=UDKVehicleWheel Name=BRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire_Cont"
		bPoweredWheel=True
	End Object
	Wheels(3)=BRWheel
}
