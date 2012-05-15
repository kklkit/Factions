class FSVehicle_Tank extends FSVehicle
	placeable;

const WheelRadius=45.0;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_LightTankMash.Mesh.SK_VH_LightTankMash'
		AnimTreeTemplate=AnimTree'VH_LightTankMash.Mesh.AT_VH_LightTankMash'
		PhysicsAsset=PhysicsAsset'VH_LightTankMash.Mesh.SK_VH_LightTankMash_Physics'
	End Object

	Begin Object Class=SVehicleSimTank Name=SimObject
		WheelSuspensionStiffness=300
		WheelSuspensionDamping=40.0
		WheelSuspensionBias=0.1
		WheelLongExtremumSlip=0
		WheelLongExtremumValue=20
		WheelLatExtremumValue=4
		ChassisTorqueScale=0.0
		StopThreshold=20
		EngineDamping=2
		InsideTrackTorqueFactor=0.45
		TurnInPlaceThrottle=0.1
		TurnMaxGripReduction=0.980
		TurnGripScaleRate=0.8
		MaxEngineTorque=3800
	End Object
	SimObj=SimObject

	Begin Object Class=UDKVehicleWheel Name=LWheel1
		BoneName="L_Wheel_1"
		SkelControlName="L_Wheel_1_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Left
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=UDKVehicleWheel Name=LWheel2
		BoneName="L_Wheel_2"
		SkelControlName="L_Wheel_2_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Left
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=UDKVehicleWheel Name=LWheel3
		BoneName="L_Wheel_3"
		SkelControlName="L_Wheel_3_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Left
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=UDKVehicleWheel Name=LWheel4
		BoneName="L_Wheel_4"
		SkelControlName="L_Wheel_4_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Left
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=UDKVehicleWheel Name=RWheel1
		BoneName="R_Wheel_1"
		SkelControlName="R_Wheel_1_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Right
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=UDKVehicleWheel Name=RWheel2
		BoneName="R_Wheel_2"
		SkelControlName="R_Wheel_2_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Right
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=UDKVehicleWheel Name=RWheel3
		BoneName="R_Wheel_3"
		SkelControlName="R_Wheel_3_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Right
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=UDKVehicleWheel Name=RWheel4
		BoneName="R_Wheel_4"
		SkelControlName="R_Wheel_4_Cont"
		SteerFactor=1.0
		WheelRadius=WheelRadius
		Side=SIDE_Right
	End Object
	Wheels(7)=RWheel4

	Seats(0)={(CameraTag=Main)}
	DrawScale=2.0
}
