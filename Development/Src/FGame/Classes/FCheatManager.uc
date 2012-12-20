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

/**
 * Spawns a crawler at the location where the player is looking.
 */
exec function SpawnCrawler()
{
	local Vector ViewLocation;
	local Rotator ViewRotation;
	local Vector HitNormal, HitLocation;
	local FCrawler Crawler;
	local FBot Bot;

	GetPlayerViewPoint(ViewLocation, ViewRotation);

	Trace(HitLocation, HitNormal, ViewLocation + 1000000 * Vector(ViewRotation), ViewLocation, True);
	
	Crawler = Spawn(class'FCrawler',,, HitLocation + vect(0, 0, 1));
	Bot = Crawler.Spawn(class'FBot',,, Crawler.Location, Crawler.Rotation);
	Bot.SetTeam(Crawler.GetTeamNum());
	Bot.Possess(Crawler, False);

	Bot.ScriptedMoveTarget = Outer.Pawn;
	Bot.PushState('ScriptedMove');
}

defaultproperties
{
}
