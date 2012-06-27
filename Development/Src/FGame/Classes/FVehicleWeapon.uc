/**
 * Base class for vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon extends Actor
	perobjectlocalized;

var int SeatIndex;
var FVehicle MyVehicle;
var	localized string ItemName;

replication
{
	if (bNetInitial && bNetOwner)
		SeatIndex, MyVehicle;
}

/**
 * Starts firing the weapon.
 */
simulated function StartFire()
{
	if (!Instigator.bNoWeaponFiring)
	{
		if (Role < Role_Authority)
		{
			ServerStartFire();
		}

		BeginFire();
	}
}

/**
 * Starts firing the weapon on the server.
 */
private reliable server function ServerStartFire()
{
	if (!Instigator.bNoWeaponFiring)
	{
		BeginFire();
	}
}

/**
 * Sets the weapon fire timer.
 */
private simulated function BeginFire()
{
	Fire();
	SetTimer(1.0, True, NameOf(Fire));
}

/**
 * Stops firing the weapon.
 */
simulated function StopFire()
{
	if (Role < Role_Authority)
	{
		ServerStopFire();
	}

	EndFire();
}

/**
 * Stops firing the weapon on the server.
 */
private reliable server function ServerStopFire()
{
	EndFire();
}

/**
 * Clears the weapon timer.
 */
private simulated function EndFire()
{
	ClearTimer(NameOf(Fire));
}

simulated function Fire();

defaultproperties
{
	NetPriority=1.4
	TickGroup=TG_PreAsyncWork
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy

	bHidden=True
	bReplicateMovement=False
	bReplicateInstigator=True
	bOnlyRelevantToOwner=True
}
