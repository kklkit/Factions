/**
 * Hitscan vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon_Instant extends FVehicleWeapon;

/**
 * @extends
 */
protected simulated function Fire()
{
	local Vector StartTraceLocation, EndTraceLocation, HitLocation, HitNormal;
	local Rotator StartTraceRotation;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local ImpactInfo Impact;

	MyVehicle.GetBarrelLocationAndRotation(SeatIndex, StartTraceLocation, StartTraceRotation);
	EndTraceLocation = StartTraceLocation + Vector(StartTraceRotation) * 65535.0;

	HitActor = Instigator.Trace(HitLocation, HitNormal, EndTraceLocation, StartTraceLocation, True,, HitInfo, TRACEFLAG_Bullet);
	if (HitActor == None)
	{
		HitLocation	= EndTraceLocation;
	}
	Impact.HitActor = HitActor;
	Impact.HitLocation = HitLocation;
	Impact.HitNormal = HitNormal;
	Impact.RayDir = Normal(EndTraceLocation - StartTraceLocation);
	Impact.StartTrace = StartTraceLocation;
	Impact.HitInfo = HitInfo;

	if (Impact.HitActor != None)
	{
		Impact.HitActor.TakeDamage(100, Instigator.Controller, Impact.HitLocation, 1.0 * Impact.RayDir, class'DamageType', Impact.HitInfo, Self);
	}
}

defaultproperties
{
}
