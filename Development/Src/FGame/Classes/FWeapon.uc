/**
 * Equippable inventory items such as rifles or repair tools.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon extends UDKWeapon
	perobjectlocalized;

var(Archetype) FWeaponClass WeaponClassArchetype;
var(Archetype) FWeaponAttachment AttachmentArchetype;
var() Vector DrawOffset;
var(Sounds)	array<SoundCue>	WeaponFireSound;
var() array<name> EffectSockets;
var int MaxAmmoCount;

var() float MovementSpread;
var() float FiringSpread;

var float CurrentFiringSpread;

replication
{
	if (bNetDirty)
		MaxAmmoCount;
}

/**
 * @extends
 */
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	UpdateSpread();
}

/**
 * Updates the weapon's current spread.
 */
function UpdateSpread()
{
	local float NewSpread;

	NewSpread = default.Spread[0];
	NewSpread += VSize2D(Instigator.Velocity) / Instigator.GroundSpeed * MovementSpread;

	if (Instigator.IsFiring())
	{
		if (CurrentFiringSpread < FiringSpread)
		{
			CurrentFiringSpread += 0.0025;
		}
	}
	else if (CurrentFiringSpread > 0)
	{
		CurrentFiringSpread -= 0.025;
	}

	NewSpread += CurrentFiringSpread;

	Spread[0] = NewSpread;
}

/**
 * @extends
 */
simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	if (Amount != 0)
		return (AmmoCount >= Amount);
	else
		return (AmmoCount > 0);
}

/**
 * @extends
 */
function ConsumeAmmo(byte FireModeNum)
{
	AddAmmo(-1);
}

/**
 * @extends
 */
simulated function bool HasAnyAmmo()
{
	return AmmoCount > 0;
}

/**
 * @extends
 */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	local FPawn PlayerPawn;

	PlayerPawn = FPawn(Instigator);
	if (PlayerPawn.IsFirstPerson())
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		Mesh.SetLightEnvironment(PlayerPawn.LightEnvironment);
	}

	// Update equipment name on the pawn to replicate to clients
	if (PlayerPawn != None && Role == ROLE_Authority)
	{
		PlayerPawn.WeaponAttachmentArchetype = AttachmentArchetype;

		// Update weapon attachment when in single player mode
		if (PlayerPawn.IsLocallyControlled())
			PlayerPawn.UpdateWeaponAttachment();
	}
}

/**
 * @extends
 */
simulated function DetachWeapon()
{
	local FPawn PlayerPawn;

	DetachComponent(Mesh);
	if (OverlayMesh != None)
		DetachComponent(OverlayMesh);

	PlayerPawn = FPawn(Instigator);

	// Clear equipment name on pawn
	if (PlayerPawn != None && Role == ROLE_Authority && FPawn(Instigator).WeaponAttachmentArchetype == AttachmentArchetype)
	{
		PlayerPawn.WeaponAttachmentArchetype = None;

		// Update weapon attachment when in single player mode
		if (Instigator.IsLocallyControlled())
			PlayerPawn.UpdateWeaponAttachment();
	}

	SetBase(None);
	SetHidden(True);
	Mesh.SetLightEnvironment(None);
}

/**
 * Toggles visibility of the first-person weapon model.
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	local SkeletalMeshComponent WeaponSkeletalMesh;
	local PrimitiveComponent SkeletalMeshPrimitive;

	if (Mesh != None)
	{
		if (bIsVisible && !Mesh.bAttached)
		{
			AttachComponent(Mesh);
			EnsureWeaponOverlayComponentLast();
		}

		SetHidden(!bIsVisible);

		WeaponSkeletalMesh = SkeletalMeshComponent(Mesh);
		if (WeaponSkeletalMesh != None)
			foreach WeaponSkeletalMesh.AttachedComponents(class'PrimitiveComponent', SkeletalMeshPrimitive)
				SkeletalMeshPrimitive.SetHidden(!bIsVisible);
	}
}

/**
 * @extends
 */
simulated event SetPosition(UDKPawn Holder)
{
	local Vector DrawLocation;

	if (!Holder.IsFirstPerson())
		return;
	
	DrawLocation = Holder.GetPawnViewLocation();
	DrawLocation += DrawOffset >> Holder.Controller.Rotation;
	DrawLocation += FPawn(Holder).WeaponBob(0.85);
	DrawLocation += UDKPlayerController(Holder.Controller).ShakeOffset >> Holder.Controller.Rotation;
	SetLocation(DrawLocation);

	SetHidden(False);
	SetBase(Holder);

	SetRotation(Holder.Controller.Rotation);
}

/**
 * @extends
 */
simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	Super.TimeWeaponEquipping();
}

/**
 * Plays a sound on the instigator.
 */
simulated function WeaponPlaySound(SoundCue Sound, optional float NoiseLoudness)
{
	if (Sound != None && Instigator != None)
	{
		Instigator.PlaySound(Sound, False, True);
	}
}

/**
 * Play the weapon's firing sound.
 */
simulated function PlayFiringSound()
{
	if (CurrentFireMode < WeaponFireSound.Length)
	{
		if (WeaponFireSound[CurrentFireMode] != None)
		{
			MakeNoise(1.0);
			WeaponPlaySound(WeaponFireSound[CurrentFireMode]);
		}
	}
}

/**
 * @extends
 */
simulated function FireAmmunition()
{
	PlayFiringSound();
	Super.FireAmmunition();
}

/**
 * Returns the location for weapon effects.
 */
simulated function Vector GetEffectLocation()
{
	local Vector SocketLocation;

	if (SkeletalMeshComponent(Mesh) != None && EffectSockets[CurrentFireMode] != '')
	{
		if (!SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndrotation(EffectSockets[CurrentFireMode], SocketLocation))
		{
			SocketLocation = Location;
		}
	}
	else if (Mesh != None)
	{
		SocketLocation = Mesh.Bounds.Origin + (Vect(45,0,0) >> Rotation);
	}
	else
	{
		SocketLocation = Location;
	}

	return SocketLocation;
}

/**
 * Draws HUD elements when weapon is active.
 */
simulated function ActiveRenderOverlays(HUD H)
{
	DrawWeaponCrosshair(H);
}

/**
 * Draws the weapon crosshair.
 */
simulated function DrawWeaponCrosshair(HUD H)
{
	local float X, Y, SpreadPixels;
	local Color CrosshairColor;
	local Vector HitLocation, HitNormal, StartTrace, EndTrace;
	local Actor HitActor;

	X = H.Canvas.ClipX / 2;
	Y = H.Canvas.ClipY / 2;
	SpreadPixels = Spread[0] * 10 * 16;

	// Set crosshair color
	StartTrace = Instigator.GetWeaponStartTraceLocation();
	EndTrace = StartTrace + Vector(GetAdjustedAim(StartTrace)) * GetTraceRange();
	HitActor = GetTraceOwner().Trace(HitLocation, HitNormal, EndTrace, StartTrace, True,,, TRACEFLAG_Bullet);

	if (Pawn(HitActor) == None)
	{
		HitActor = (HitActor == None) ? None : Pawn(HitActor.Base);
	}

	if ((Pawn(HitActor) == None) || !Worldinfo.GRI.OnSameTeam(HitActor, Instigator))
	{
		CrosshairColor.R = 255;
		CrosshairColor.G = 0;
		CrosshairColor.B = 0;
		CrosshairColor.A = 255;
	}
	else
	{
		CrosshairColor.R = 0;
		CrosshairColor.G = 255;
		CrosshairColor.B = 0;
		CrosshairColor.A = 255;
	}

	H.Canvas.Draw2DLine(X, Y - 16 - SpreadPixels, X, Y - 2 - SpreadPixels, CrosshairColor);
	H.Canvas.Draw2DLine(X, Y + 2 + SpreadPixels, X, Y + 16 + SpreadPixels, CrosshairColor);
	H.Canvas.Draw2DLine(X - 16 - SpreadPixels, Y, X - 2 - SpreadPixels, Y, CrosshairColor);
	H.Canvas.Draw2DLine(X + 2 + SpreadPixels, Y, X + 16 + SpreadPixels, Y, CrosshairColor);
}

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bOnlyOwnerSee=True
		bOverrideAttachmentOwnerVisibility=True
		Rotation=(Yaw=-16384)
	End Object
	Mesh=FirstPersonMesh

	bCanThrow=False

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamage(0)=10.0
	InstantHitMomentum(0)=0.0
	InstantHitDamageTypes(0)=class'DamageType'
	ShouldFireOnRelease(0)=0
	EquipTime=0.0
	PutDownTime=0.0
	FireInterval(0)=0.1
	Spread(0)=0.01
	EffectSockets(0)=Muzzle

	MovementSpread=0.1
	FiringSpread=0.1
}
