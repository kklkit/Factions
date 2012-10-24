class FWeaponPawn extends UDKWeaponPawn;

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'MyVehicle' || VarName == 'MyVehicleWeapon' || VarName == 'MySeatIndex')
	{
		if (MySeatIndex > 0 && MyVehicle != None && MySeatIndex < MyVehicle.Seats.Length)
		{
			MyVehicle.Seats[MySeatIndex].SeatPawn = Self;
			MyVehicle.Seats[MySeatIndex].Gun = MyVehicleWeapon;
			SetBase(MyVehicle);
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/**
 * @extends
 */
simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV)
{
	if (MyVehicle != None && MySeatIndex > 0 && MySeatIndex < MyVehicle.Seats.Length)
	{
		FVehicle(MyVehicle).VehicleCalcCamera(fDeltaTime, MySeatIndex, out_CamLoc, out_CamRot, out_FOV);
		return True;
	}
	else
	{
		return Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}
}

/**
 * @extends
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local Canvas Canvas;

	Canvas = HUD.Canvas;

	Super.DisplayDebug(HUD, out_YL, out_YPos);

	Canvas.SetPos(4, out_YPos);
	Canvas.DrawText("[WeaponPawn]");
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);
	Canvas.DrawText("Owner:" @ Owner);
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);
	Canvas.DrawText("Vehicle:" @ MyVehicleWeapon @ MyVehicle);
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);
	Canvas.DrawText("Rotation/Location:" @ Rotation @ Location);
	out_YPos += out_YL;

	if (MyVehicle != None)
	{
		MyVehicle.DisplayDebug(HUD, out_YL, out_YPos);
	}
}

/**
 * @extends
 */
simulated function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, out rotator out_DeltaRot)
{
	local int i, MaxDelta;
	local float MaxDeltaDegrees;

	if (WorldInfo.bUseConsoleInput && MyVehicle != None)
	{
		// clamp player rotation to turret rotation speed
		for (i = 0; i < MyVehicle.Seats[MySeatIndex].TurretControllers.length; i++)
		{
			MaxDeltaDegrees = FMax(MaxDeltaDegrees, MyVehicle.Seats[MySeatIndex].TurretControllers[i].LagDegreesPerSecond);
		}
		if (MaxDeltaDegrees > 0.0)
		{
			MaxDelta = int(MaxDeltaDegrees * 182.0444 * DeltaTime);
			out_DeltaRot.Pitch = (out_DeltaRot.Pitch >= 0) ? Min(out_DeltaRot.Pitch, MaxDelta) : Max(out_DeltaRot.Pitch, -MaxDelta);
			out_DeltaRot.Yaw = (out_DeltaRot.Yaw >= 0) ? Min(out_DeltaRot.Yaw, MaxDelta) : Max(out_DeltaRot.Yaw, -MaxDelta);
			out_DeltaRot.Roll = (out_DeltaRot.Roll >= 0) ? Min(out_DeltaRot.Roll, MaxDelta) : Max(out_DeltaRot.Roll, -MaxDelta);
		}
	}
	Super.ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);
}

/**
 * @extends
 */
simulated function SetFiringMode(Weapon Weap, byte FiringModeNum)
{
	if (MyVehicle != None && MySeatIndex > 0 && MySeatIndex < MyVehicle.Seats.Length)
	{
		FVehicle(MyVehicle).SeatFiringMode(MySeatIndex, FiringModeNum, False);
	}
}

/**
 * @extends
 */
function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);
	MyVehicleWeapon.ClientWeaponSet(False);
	SetBaseEyeHeight();
	EyeHeight = BaseEyeHeight;
}

/**
 * @extends
 */
reliable server function ServerChangeSeat(int RequestedSeat)
{
	if (MyVehicle != None)
	{
		FVehicle(MyVehicle).ChangeSeat(Controller, RequestedSeat);
	}
}

/**
 * @extends
 */
function DriverLeft()
{
	Super.DriverLeft();
	FVehicle(MyVehicle).PassengerLeave(MySeatIndex);
}

/**
 * @extends
 */
simulated function SetBaseEyeheight()
{
	BaseEyeHeight = MyVehicle.Seats[MySeatIndex].CameraEyeHeight;
}

/**
 * @extends
 */
simulated function FaceRotation(Rotator NewRotation, float DeltaTime)
{
	SetRotation(NewRotation);
}

/**
 * @extends
 */
function bool Died(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
	local PlayerController OldPC;

	OldPC = PlayerController(Controller);
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		GotoState('Dying');
		HandleDeadVehicleDriver();
		if (OldPC != None && MyVehicle != None)
		{
			OldPC.SetViewTarget(MyVehicle);
		}
		Destroy();
		return True;
	}
	else
	{
		return False;
	}
}

/**
 * Rotates the turret by the given amount.
 */
simulated function RotateTurret(Rotator RotationAmount)
{
	local int i;
	local TurretControl TC;
	local FVehicle V;

	V = FVehicle(MyVehicle);
	
	foreach V.TurretControls(TC, i)
	{
		if (TC.SeatIndex == MySeatIndex)
		{
			// Only update rotation if there is any rotation amount
			if (RotationAmount.Pitch != 0 || RotationAmount.Roll != 0 || RotationAmount.Yaw != 0)
			{
				TC.RotateController.DesiredBoneRotation += RotationAmount;
				V.ApplyTurretConstraints(TC);
				V.TurretRotations[i] = TC.RotateController.DesiredBoneRotation;

				if (Role < ROLE_Authority)
					ServerSetTurretRotation(i, TC.RotateController.DesiredBoneRotation);
			}
		}
	}
}

/**
 * Sets the weapon rotation on the server.
 */
unreliable server function ServerSetTurretRotation(int ControlIndex, Rotator NewTurretRotation)
{
	local FVehicle V;

	V = FVehicle(MyVehicle);

	V.TurretControls[ControlIndex].RotateController.DesiredBoneRotation = NewTurretRotation;
	V.TurretRotations[ControlIndex] = V.TurretControls[ControlIndex].RotateController.DesiredBoneRotation;

	//TODO: Figure out why bNetDirty has to be manually set for turret rotation to replicate
	V.bNetDirty = True;
}

defaultproperties
{
	Physics=PHYS_None
	bProjTarget=False
	bOnlyRelevantToOwner=True

	bCollideActors=False
	bCollideWorld=False

	Begin Object Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
		BlockNonZeroExtent=False
		BlockZeroExtent=False
		BlockActors=False
		CollideActors=False
		BlockRigidBody=False
	End Object

	BaseEyeheight=180
	EyeHeight=180

	bIgnoreBaseRotation=True
	bStationary=True
	bFollowLookDir=True
	bTurnInPlace=True

	MySeatIndex=INDEX_NONE
}
