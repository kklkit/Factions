class FPlayerReplicationInfo extends PlayerReplicationInfo;

// Orders
var Vector OrderLocation;

replication
{
	if (bNetDirty)
		OrderLocation;
}