/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle_Car8 extends FVehicle;

defaultproperties
{
	Begin Object Class=UDKVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=100.0
		WheelSuspensionDamping=3.0
		WheelSuspensionBias=0.1
		ChassisTorqueScale=0.0
		MaxBrakeTorque=5.0
		StopThreshold=100.0

		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=45),(InVal=600.0,OutVal=15.0),(InVal=1100.0,OutVal=10.0),(InVal=1300.0,OutVal=6.0),(InVal=1600.0,OutVal=1.0)))
		SteerSpeed=110

		LSDFactor=0.0
		TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=80.0),(InVal=0.0,OutVal=130.0),(InVal=950.0,OutVal=130.0),(InVal=1050.0,OutVal=10.0),(InVal=1150.0,OutVal=0.0)))
		EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=549.0,OutVal=3500.0),(InVal=550.0,OutVal=1000.0),(InVal=849.0,OutVal=4500.0),(InVal=850.0,OutVal=1500.0),(InVal=1100.0,OutVal=5000.0)))
		EngineBrakeFactor=0.025
		ThrottleSpeed=0.2
		WheelInertia=0.2
		NumWheelsForFullSteering=2
		SteeringReductionFactor=0.0
		SteeringReductionMinSpeed=1100.0
		SteeringReductionSpeed=1400.0
		bAutoHandbrake=True
		bClampedFrictionModel=True
		FrontalCollisionGripFactor=0.18
		ConsoleHardTurnGripFactor=1.0
		HardTurnMotorTorque=0.7

		SpeedBasedTurnDamping=20.0
		AirControlTurnTorque=40.0
		InAirUprightMaxTorque=15.0
		InAirUprightTorqueFactor=-30.0

		WheelLongExtremumSlip=0.1
		WheelLongExtremumValue=1.0
		WheelLongAsymptoteSlip=2.0
		WheelLongAsymptoteValue=0.6

		WheelLatExtremumSlip=0.35
		WheelLatExtremumValue=0.9
		WheelLatAsymptoteSlip=1.4
		WheelLatAsymptoteValue=0.9

		bAutoDrive=False
		AutoDriveSteer=0.3
	End Object
	SimObj=SimObject

	Begin Object Class=UDKVehicleWheel Name=LWheel1
		BoneName="L_Tire_1"
		SkelControlName="L_Tire_1_Cont"
		SteerFactor=1.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Left
	End Object
	Wheels(0)=LWheel1

	Begin Object Class=UDKVehicleWheel Name=LWheel2
		BoneName="L_Tire_2"
		SkelControlName="L_Tire_2_Cont"
		SteerFactor=0.5
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Left
	End Object
	Wheels(1)=LWheel2

	Begin Object Class=UDKVehicleWheel Name=LWheel3
		BoneName="L_Tire_3"
		SkelControlName="L_Tire_3_Cont"
		SteerFactor=0.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Left
	End Object
	Wheels(2)=LWheel3

	Begin Object Class=UDKVehicleWheel Name=LWheel4
		BoneName="L_Tire_4"
		SkelControlName="L_Tire_4_Cont"
		SteerFactor=0.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Left
	End Object
	Wheels(3)=LWheel4

	Begin Object Class=UDKVehicleWheel Name=RWheel1
		BoneName="R_Tire_1"
		SkelControlName="R_Tire_1_Cont"
		SteerFactor=1.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Right
	End Object
	Wheels(4)=RWheel1

	Begin Object Class=UDKVehicleWheel Name=RWheel2
		BoneName="R_Tire_2"
		SkelControlName="R_Tire_2_Cont"
		SteerFactor=0.5
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Right
	End Object
	Wheels(5)=RWheel2

	Begin Object Class=UDKVehicleWheel Name=RWheel3
		BoneName="R_Tire_3"
		SkelControlName="R_Tire_3_Cont"
		SteerFactor=0.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Right
	End Object
	Wheels(6)=RWheel3

	Begin Object Class=UDKVehicleWheel Name=RWheel4
		BoneName="R_Tire_4"
		SkelControlName="R_Tire_4_Cont"
		SteerFactor=0.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
		Side=SIDE_Right
	End Object
	Wheels(7)=RWheel4

	GroundSpeed=950
	AirSpeed=1100
	HeavySuspensionShiftPercent=0.75
}
