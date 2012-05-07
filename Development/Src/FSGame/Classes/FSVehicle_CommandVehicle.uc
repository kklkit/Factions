/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle_CommandVehicle extends FSVehicle;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Scorpion.Mesh.SK_VH_Scorpion_001'
		AnimTreeTemplate=AnimTree'VH_Scorpion.Anims.AT_VH_Scorpion_001'
		PhysicsAsset=PhysicsAsset'VH_Scorpion.Mesh.SK_VH_Scorpion_001_Physics'
	End Object

	Begin Object Class=SVehicleWheel Name=FLWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire_Cont"
		WheelRadius=10.f
	End Object
	Wheels(0)=FLWheel

	Begin Object Class=SVehicleWheel Name=FRWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire_Cont"
		WheelRadius=10.f
	End Object
	Wheels(1)=FRWheel

	Begin Object Class=SVehicleWheel Name=BLWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire_Cont"
		WheelRadius=10.f
	End Object
	Wheels(2)=BLWheel

	Begin Object Class=SVehicleWheel Name=BRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire_Cont"
		WheelRadius=10.f
	End Object
	Wheels(3)=BRWheel
}
