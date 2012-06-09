/**
 * Player-specific information that is replicated to all clients.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPlayerReplicationInfo extends PlayerReplicationInfo;

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	// Refresh the team GUI when the player's team has changed
	if (VarName == 'Team')
		FHUD(GetALocalPlayerController().myHUD).GFxOmniMenu.Invalidate("team");

	Super.ReplicatedEvent(VarName);
}
