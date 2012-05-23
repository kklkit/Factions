/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPlayerReplicationInfo extends PlayerReplicationInfo;

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'Team')
		FHUD(GetALocalPlayerController().myHUD).GFxOmniMenu.Invalidate("team");

	Super.ReplicatedEvent(VarName);
}

defaultproperties
{
}
