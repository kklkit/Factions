/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle_CommandVehicle extends FSVehicle;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_CommandVehicleMash.Mesh.SK_VH_CommandVehicleMash'
		AnimTreeTemplate=AnimTree'VH_CommandVehicleMash.Anims.AT_VH_CommandVehicleMash'
		PhysicsAsset=PhysicsAsset'VH_CommandVehicleMash.Mesh.SK_VH_CommandVehicleMash_Physics'
	End Object

	Begin Object Class=SVehicleWheel Name=LWheel1
		BoneName="L_Tire_1"
		SkelControlName="L_Tire_1_Cont"
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=SVehicleWheel Name=LWheel2
		BoneName="L_Tire_2"
		SkelControlName="L_Tire_2_Cont"
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=SVehicleWheel Name=LWheel3
		BoneName="L_Tire_3"
		SkelControlName="L_Tire_3_Cont"
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=SVehicleWheel Name=LWheel4
		BoneName="L_Tire_4"
		SkelControlName="L_Tire_4_Cont"
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=SVehicleWheel Name=RWheel1
		BoneName="R_Tire_1"
		SkelControlName="R_Tire_1_Cont"
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=SVehicleWheel Name=RWheel2
		BoneName="R_Tire_2"
		SkelControlName="R_Tire_2_Cont"
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=SVehicleWheel Name=RWheel3
		BoneName="R_Tire_3"
		SkelControlName="R_Tire_3_Cont"
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=SVehicleWheel Name=RWheel4
		BoneName="R_Tire_4"
		SkelControlName="R_Tire_4_Cont"
	End Object
	Wheels(7)=RWheel4
}
