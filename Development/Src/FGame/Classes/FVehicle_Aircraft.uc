class FVehicle_Aircraft extends FVehicle;

defaultproperties
{
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
		TurnDamping=1.2
		MaxYawRate=1.8
		PitchTorqueFactor=450.0
		PitchTorqueMax=60.0
		PitchDamping=0.3
		RollTorqueTurnFactor=700.0
		RollTorqueStrafeFactor=100.0
		RollTorqueMax=300.0
		RollDamping=0.1
		MaxRandForce=30.0
		RandForceInterval=0.5
		StopThreshold=100.0
		bShouldCutThrustMaxOnImpact=True
	End Object
	SimObj=SimObject

	AirSpeed=2000.0
	GroundSpeed=1600.0

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0

	bStayUpright=True
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=1200
	StayUprightDamping=20

	bHomingTarget=True
	bNoZDampingInAir=False

	bCanStrafe=True
	bCanFly=True
	bTurnInPlace=True
	bFollowLookDir=True

	bEjectPassengersWhenFlipped=False
	UpsideDownDamagePerSec=0.0

	bUseAlternatePaths=False
	
	bJostleWhileDriving=True
	bFloatWhenDriven=True
}
