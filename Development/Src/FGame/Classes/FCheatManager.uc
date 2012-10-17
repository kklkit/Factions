/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FCheatManager extends GameCheatManager within GamePlayerController;

/**
 * Kills the pawn the player is looking at.
 */
exec function KillTarget()
{
	local Actor HitActor;
	local Vector HitNormal, HitLocation;
	local Vector ViewLocation;
	local Rotator ViewRotation;

	GetPlayerViewPoint(ViewLocation, ViewRotation);

	HitActor = Trace(HitLocation, HitNormal, ViewLocation + 1000000 * Vector(ViewRotation), ViewLocation, True);

	if (Pawn(HitActor) != None)
	{
		Pawn(HitActor).Died(None, class'DmgType_Suicided', Pawn(HitActor).Location);
	}
}

defaultproperties
{
}
