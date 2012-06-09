/**
 * Base class for tracked vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle_Tank extends FVehicle;

defaultproperties
{
	Begin Object Class=SVehicleSimTank Name=SimObject
	End Object
	SimObj=SimObject

	Begin Object Class=UDKVehicleWheel Name=LWheel1
		BoneName="L_Wheel_1"
		SkelControlName="L_Wheel_1_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=UDKVehicleWheel Name=LWheel2
		BoneName="L_Wheel_2"
		SkelControlName="L_Wheel_2_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=UDKVehicleWheel Name=LWheel3
		BoneName="L_Wheel_3"
		SkelControlName="L_Wheel_3_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=UDKVehicleWheel Name=LWheel4
		BoneName="L_Wheel_4"
		SkelControlName="L_Wheel_4_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=UDKVehicleWheel Name=RWheel1
		BoneName="R_Wheel_1"
		SkelControlName="R_Wheel_1_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=UDKVehicleWheel Name=RWheel2
		BoneName="R_Wheel_2"
		SkelControlName="R_Wheel_2_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=UDKVehicleWheel Name=RWheel3
		BoneName="R_Wheel_3"
		SkelControlName="R_Wheel_3_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=UDKVehicleWheel Name=RWheel4
		BoneName="R_Wheel_4"
		SkelControlName="R_Wheel_4_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
	End Object
	Wheels(7)=RWheel4
}
