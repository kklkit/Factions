class FVehicle_Hover extends FVehicle;

defaultproperties
{
	Begin Object Class=UDKVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=20.0
		WheelSuspensionDamping=1.0
		WheelSuspensionBias=0.0
		MaxThrustForce=325.0
		MaxReverseForce=250.0
		LongDamping=0.3
		MaxStrafeForce=260.0
		DirectionChangeForce=375.0
		LatDamping=0.3
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=2500.0
		TurnTorqueMax=1000.0
		TurnDamping=0.25
		MaxYawRate=100000.0
		PitchTorqueFactor=200.0
		PitchTorqueMax=18.0
		PitchDamping=0.1
		RollTorqueTurnFactor=1000.0
		RollTorqueStrafeFactor=110.0
		RollTorqueMax=500.0
		RollDamping=0.2
		MaxRandForce=20.0
		RandForceInterval=0.4
		bAllowZThrust=false
	End Object
	SimObj=SimObject

	Begin Object Class=UTHoverWheel Name=RThruster
		BoneName="R_Thruster"
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(0)=RThruster

	Begin Object Class=UTHoverWheel Name=LThruster
		BoneName="L_Thruster"
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(1)=LThruster

	Begin Object Class=UTHoverWheel Name=FThruster
		BoneName="Root"
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(2)=FThruster

	AirSpeed=1800.0
	GroundSpeed=1500.0

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=450
	StayUprightDamping=20
}
