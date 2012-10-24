class FCheatManager extends GameCheatManager within GamePlayerController;

/**
 * Kills the pawn that the player is looking at.
 */
exec function KillTarget()
{
	local Vector ViewLocation;
	local Rotator ViewRotation;
	local Actor HitActor;
	local Vector HitNormal, HitLocation;

	GetPlayerViewPoint(ViewLocation, ViewRotation);

	HitActor = Trace(HitLocation, HitNormal, ViewLocation + 1000000 * Vector(ViewRotation), ViewLocation, True);

	if (Pawn(HitActor) != None)
	{
		Pawn(HitActor).Died(Outer, class'DmgType_Suicided', Pawn(HitActor).Location);
	}
}

defaultproperties
{
}
