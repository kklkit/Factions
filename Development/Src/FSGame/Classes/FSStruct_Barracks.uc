/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_Barracks extends FSStructure;

event PostBeginPlay()
{
	local Vector PlayerStartLocation;
	local FSTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	PlayerStartLocation.X = Location.X + 200;
	PlayerStartLocation.Y = Location.Y + 200;
	PlayerStartLocation.Z = Location.Z + 125;

	BarracksPlayerStart = Spawn(class'FSTeamPlayerStart', self,, PlayerStartLocation,,,);

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
