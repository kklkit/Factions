class FSVehicle_Gunship extends FSVehicle
	placeable;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_GunshipMash.Mesh.SK_VH_GunshipMash'
		AnimTreeTemplate=AnimTree'VH_GunshipMash.Anims.AT_VH_GunshipMash'
		PhysicsAsset=PhysicsAsset'VH_GunshipMash.Mesh.SK_VH_GunshipMash_Physics'
	End Object

	Begin Object Class=UDKVehicleSimChopper Name=SimObject
		MaxThrustForce=700.0
		MaxReverseForce=700.0
		LongDamping=0.6
		MaxStrafeForce=680.0
		LatDamping=0.7
		MaxRiseForce=1000.0
		UpDamping=0.7
		TurnTorqueFactor=7000.0
		TurnTorqueMax=10000.0
		TurnDamping=5.0
		MaxYawRate=1.8
		PitchTorqueFactor=450.0
		PitchTorqueMax=60.0
		PitchDamping=5.0
		RollTorqueTurnFactor=700.0
		RollTorqueStrafeFactor=100.0
		RollTorqueMax=300.0
		RollDamping=0.1
		MaxRandForce=30.0
		RandForceInterval=0.5
		StopThreshold=100
		bShouldCutThrustMaxOnImpact=True
	End Object
	SimObj=SimObject

	Seats(0)={(CameraTag=Main)}

	bHomingTarget=True
	bNoZDampingInAir=False

	bCanStrafe=True
	bCanFly=True
	bTurnInPlace=True
	bFollowLookDir=True

	bEjectPassengersWhenFlipped=False
	UpsideDownDamagePerSec=0.0

	bJostleWhileDriving=True
	bFloatWhenDriven=True

	AirSpeed=2000.0
	GroundSpeed=1600.0

	bStayUpright=True
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=1200
	StayUprightDamping=20
}
