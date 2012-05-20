/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle_Jeep extends FSVehicle;

const TireRadius=60.0;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_JeepMash.Mesh.SK_VH_JeepMash'
		AnimTreeTemplate=AnimTree'VH_JeepMash.Anims.AT_VH_JeepMash'
		PhysicsAsset=PhysicsAsset'VH_JeepMash.Mesh.SK_VH_JeepMash_Physics'
	End Object

	Begin Object Class=UDKVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=25.0
		WheelSuspensionDamping=2.0
		WheelSuspensionBias=0.0
		bClampedFrictionModel=True

		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=35),(InVal=2000.0,OutVal=5.0)))
		EngineBrakeFactor=0.1
		MaxBrakeTorque=5.0
		SteerSpeed=100

		TorqueVSpeedCurve=(Points=((InVal=-1000.0,OutVal=10.0),(InVal=0.0,OutVal=250.0),(InVal=2000.0,OutVal=10.0)))
	End Object
	SimObj=SimObject
	Components.Add(SimObject);

	Begin Object Class=UDKVehicleWheel Name=FLWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire_Cont"
		WheelRadius=TireRadius
		SteerFactor=1.0
		bPoweredWheel=True
	End Object
	Wheels(0)=FLWheel

	Begin Object Class=UDKVehicleWheel Name=FRWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire_Cont"
		WheelRadius=TireRadius
		SteerFactor=1.0
		bPoweredWheel=True
	End Object
	Wheels(1)=FRWheel

	Begin Object Class=UDKVehicleWheel Name=BLWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=True
	End Object
	Wheels(2)=BLWheel

	Begin Object Class=UDKVehicleWheel Name=BRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=True
	End Object
	Wheels(3)=BRWheel

	COMOffset=(x=0.0,y=0.0,z=-35.0)
	Seats(0)={(CameraTag=Main_Root)}
	AirSpeed=2000
}
