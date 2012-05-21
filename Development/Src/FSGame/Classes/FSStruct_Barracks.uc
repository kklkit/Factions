/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_Barracks extends FSStructure;

event PostBeginPlay()
{
	local Vector PlayerStartLocation;
	local FSTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	Mesh.GetSocketWorldLocationAndRotation('Spawn_Point', PlayerStartLocation);

	BarracksPlayerStart = Spawn(class'FSTeamPlayerStart', Self,, PlayerStartLocation,,,);

	if (BarracksPlayerStart != None)
	{
		BarracksPlayerStart.TeamNumber = Team;
		BarracksPlayerStart.TeamIndex = Team;
	}
}

defaultproperties
{
	Begin Object Name=StructureMesh
		SkeletalMesh=SkeletalMesh'ST_BarracksMash.Mesh.SK_ST_BarracksMash'
		PhysicsAsset=PhysicsAsset'ST_BarracksMash.Mesh.SK_ST_BarracksMash_Physics'
	End Object

	DrawScale=1.2
}
