/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPlayerReplicationInfo extends PlayerReplicationInfo;

// Orders
var Vector OrderLocation;

replication
{
	if (bNetDirty)
		OrderLocation;
}