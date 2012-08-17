/**
 * Base class for 4-wheeled vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle_Car extends FVehicle;

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
		NumWheelsForFullSteering=4
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

	Begin Object Class=UDKVehicleWheel Name=FLWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire_Cont"
		SteerFactor=1.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(0)=FLWheel

	Begin Object Class=UDKVehicleWheel Name=FRWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire_Cont"
		SteerFactor=1.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=3.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(1)=FRWheel

	Begin Object Class=UDKVehicleWheel Name=BLWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire_Cont"
		SteerFactor=0.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=2.75
		HandbrakeLongSlipFactor=0.7
		HandbrakeLatSlipFactor=0.3
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(2)=BLWheel

	Begin Object Class=UDKVehicleWheel Name=BRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire_Cont"
		SteerFactor=0.0
		SuspensionTravel=40
		LongSlipFactor=2.0
		LatSlipFactor=2.75
		HandbrakeLongSlipFactor=0.7
		HandbrakeLatSlipFactor=0.3
		ParkedSlipFactor=10.0
		bPoweredWheel=True
		bUseMaterialSpecificEffects=True
	End Object
	Wheels(3)=BRWheel

	GroundSpeed=950
	AirSpeed=1100
	HeavySuspensionShiftPercent=0.75
}
