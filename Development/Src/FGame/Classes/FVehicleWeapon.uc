class FVehicleWeapon extends FWeapon
	perobjectlocalized;

var int SeatIndex;
var int WeaponIndex;
var FVehicle MyVehicle;

var() enum EHardpointTypes
{
	H_Gun,
	H_Cannon,
	H_Missile
} HardpointType;

replication
{
	if (bNetInitial && bNetOwner)
		SeatIndex, WeaponIndex, MyVehicle;
}

/**
 * Returns true if the weapon is pending fire.
 */
simulated function bool VehiclePendingFire(int FireMode)
{
	if (FVehicleInventoryManager(InvManager) != None)
	{
		return FVehicleInventoryManager(InvManager).IsVehiclePendingFire(Self, FireMode);
	}
	return False;
}

/**
 * @extends
 */
simulated function ForceEndFire()
{
	local int i, Num;

	// Clear all pending fires
	if (FVehicleInventoryManager(InvManager) != None)
	{
		Num = GetPendingFireLength();
		for (i = 0; i < Num; i++)
		{
			if (VehiclePendingFire(i))
			{
				EndFire(i);
			}
		}
	}
}

/**
 * @extends
 */
simulated function bool StillFiring(byte FireMode)
{
	return (VehiclePendingFire(FireMode));
}

/**
 * @extends
 */
simulated function BeginFire(byte FireModeNum)
{
	SetPendingFire(FireModeNum);
}

/**
 * @extends
 */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName);

/**
 * @extends
 */
simulated function DetachWeapon();

auto state Active
{

	/**
	 * @extends
	 */
	simulated event BeginState(Name PreviousStateName)
	{
		local int i;

		for (i = 0; i < GetPendingFireLength(); i++)
		{
			if (VehiclePendingFire(i))
			{
				BeginFire(i);
				break;
			}
		}
	}

	/**
	 * @extends
	 */
	simulated function BeginFire(byte FireModeNum)
	{
		if (!bDeleteMe && Instigator != None)
		{
			Global.BeginFire(FireModeNum);

			if (VehiclePendingFire(FireModeNum) && HasAmmo(FireModeNum))
			{
				SendToFiringState(FireModeNum);
			}
		}
	}
}

defaultproperties
{
	AmmoCount=1000
	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring
}
