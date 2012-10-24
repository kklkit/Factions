class FVehicle_Tank extends FVehicle;

/**
 * @extends
 */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (EngineSound != None)
	{
		EngineSound.SetFloatParameter('EnginePitchParam', VSize(Velocity));
	}
}

defaultproperties
{
	Begin Object Class=SVehicleSimTank Name=SimObject
		MaxEngineTorque=7800.0
		EngineDamping=4.1
		InsideTrackTorqueFactor=0.25
		TurnInPlaceThrottle=0.5
		StopThreshold=50.0
		WheelSuspensionStiffness=500.0
		WheelSuspensionDamping=40.0
		WheelSuspensionBias=0.1
		WheelLongExtremumSlip=1.5
	End Object
	SimObj=SimObject

	Begin Object Class=UDKVehicleWheel Name=LWheel1
		BoneName="L_Wheel_1"
		SkelControlName="L_Wheel_1_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
		EffectDesiredSpinDir=-1.0
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=UDKVehicleWheel Name=LWheel2
		BoneName="L_Wheel_2"
		SkelControlName="L_Wheel_2_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=UDKVehicleWheel Name=LWheel3
		BoneName="L_Wheel_3"
		SkelControlName="L_Wheel_3_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=UDKVehicleWheel Name=LWheel4
		BoneName="L_Wheel_4"
		SkelControlName="L_Wheel_4_Cont"
		SteerFactor=1.0
		Side=SIDE_Left
		EffectDesiredSpinDir=1.0
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=UDKVehicleWheel Name=RWheel1
		BoneName="R_Wheel_1"
		SkelControlName="R_Wheel_1_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
		EffectDesiredSpinDir=-1.0
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=UDKVehicleWheel Name=RWheel2
		BoneName="R_Wheel_2"
		SkelControlName="R_Wheel_2_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=UDKVehicleWheel Name=RWheel3
		BoneName="R_Wheel_3"
		SkelControlName="R_Wheel_3_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=UDKVehicleWheel Name=RWheel4
		BoneName="R_Wheel_4"
		SkelControlName="R_Wheel_4_Cont"
		SteerFactor=1.0
		Side=SIDE_Right
		EffectDesiredSpinDir=1.0
		SuspensionTravel=45.0
		LongSlipFactor=250.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(7)=RWheel4

	MomentumMult=0.300000
	GroundSpeed=520.0
	MaxSpeed=900.0
	bCanStrafe=True
	bTurnInPlace=True
}
