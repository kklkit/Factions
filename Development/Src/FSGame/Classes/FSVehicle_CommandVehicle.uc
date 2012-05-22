/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle_CommandVehicle extends FSVehicle;

const TireRadius=65.0;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_CommandVehicleMash.Mesh.SK_VH_CommandVehicleMash'
		AnimTreeTemplate=AnimTree'VH_CommandVehicleMash.Anims.AT_VH_CommandVehicleMash'
		PhysicsAsset=PhysicsAsset'VH_CommandVehicleMash.Mesh.SK_VH_CommandVehicleMash_Physics'
	End Object

	Begin Object Class=UDKVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=400.0
		WheelSuspensionDamping=60.0
		WheelSuspensionBias=0.0
		bClampedFrictionModel=True

		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=35),(InVal=1150.0,OutVal=5.0)))
		EngineBrakeFactor=0.02
		MaxBrakeTorque=5.0
		SteerSpeed=100

		TorqueVSpeedCurve=(Points=((InVal=-1000.0,OutVal=10.0),(InVal=0.0,OutVal=250.0),(InVal=1150.0,OutVal=10.0)))
	End Object
	SimObj=SimObject
	Components.Add(SimObject);

	Begin Object Class=UDKVehicleWheel Name=LWheel1
		BoneName="L_Tire_1"
		SkelControlName="L_Tire_1_Cont"
		WheelRadius=TireRadius
		SteerFactor=1.0
		bPoweredWheel=True
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=UDKVehicleWheel Name=LWheel2
		BoneName="L_Tire_2"
		SkelControlName="L_Tire_2_Cont"
		WheelRadius=TireRadius
		SteerFactor=0.25
		bPoweredWheel=True
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=UDKVehicleWheel Name=LWheel3
		BoneName="L_Tire_3"
		SkelControlName="L_Tire_3_Cont"
		WheelRadius=TireRadius
		SteerFactor=-0.25
		bPoweredWheel=True
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=UDKVehicleWheel Name=LWheel4
		BoneName="L_Tire_4"
		SkelControlName="L_Tire_4_Cont"
		WheelRadius=TireRadius
		SteerFactor=-1.0
		bPoweredWheel=True
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=UDKVehicleWheel Name=RWheel1
		BoneName="R_Tire_1"
		SkelControlName="R_Tire_1_Cont"
		WheelRadius=TireRadius
		SteerFactor=1.0
		bPoweredWheel=True
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=UDKVehicleWheel Name=RWheel2
		BoneName="R_Tire_2"
		SkelControlName="R_Tire_2_Cont"
		WheelRadius=TireRadius
		SteerFactor=0.25
		bPoweredWheel=True
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=UDKVehicleWheel Name=RWheel3
		BoneName="R_Tire_3"
		SkelControlName="R_Tire_3_Cont"
		WheelRadius=TireRadius
		SteerFactor=-0.25
		bPoweredWheel=True
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=UDKVehicleWheel Name=RWheel4
		BoneName="R_Tire_4"
		SkelControlName="R_Tire_4_Cont"
		WheelRadius=TireRadius
		SteerFactor=-1.0
		bPoweredWheel=True
	End Object
	Wheels(7)=RWheel4

	COMOffset=(x=0.0,y=0.0,z=-40.0)
	Seats(0)={(CameraTag=Main_Root)}
	DrawScale=2.6
	AirSpeed=1150
	ExitRadius=200.0
}
