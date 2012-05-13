/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle_CommandVehicle extends FSVehicle
	placeable;

const TireRadius=80.f;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_CommandVehicleMash.Mesh.SK_VH_CommandVehicleMash'
		AnimTreeTemplate=AnimTree'VH_CommandVehicleMash.Anims.AT_VH_CommandVehicleMash'
		PhysicsAsset=PhysicsAsset'VH_CommandVehicleMash.Mesh.SK_VH_CommandVehicleMash_Physics'
	End Object

	Begin Object Class=UDKVehicleSimCar Name=SimObject
	End Object
	SimObj=SimObject
	Components.Add(SimObject);

	Begin Object Class=UDKVehicleWheel Name=LWheel1
		BoneName="L_Tire_1"
		SkelControlName="L_Tire_1_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=UDKVehicleWheel Name=LWheel2
		BoneName="L_Tire_2"
		SkelControlName="L_Tire_2_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=UDKVehicleWheel Name=LWheel3
		BoneName="L_Tire_3"
		SkelControlName="L_Tire_3_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=UDKVehicleWheel Name=LWheel4
		BoneName="L_Tire_4"
		SkelControlName="L_Tire_4_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=UDKVehicleWheel Name=RWheel1
		BoneName="R_Tire_1"
		SkelControlName="R_Tire_1_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=UDKVehicleWheel Name=RWheel2
		BoneName="R_Tire_2"
		SkelControlName="R_Tire_2_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=UDKVehicleWheel Name=RWheel3
		BoneName="R_Tire_3"
		SkelControlName="R_Tire_3_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=UDKVehicleWheel Name=RWheel4
		BoneName="R_Tire_4"
		SkelControlName="R_Tire_4_Cont"
		WheelRadius=TireRadius
		bPoweredWheel=true
	End Object
	Wheels(7)=RWheel4

	Seats(0)={(CameraTag=Main_Root)}

	DrawScale=3.f
}
