/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStructure extends Vehicle
	abstract;

var() byte Team;

function bool AnySeatAvailable()
{
	return False;
}

simulated event byte ScriptGetTeamNum()
{
	return Team;
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=UDKSkeletalMeshComponent Name=StructureMesh
		LightEnvironment=LightEnvironment0
		CollideActors=True
		BlockActors=True
		BlockRigidBody=True
		BlockZeroExtent=True
		BlockNonZeroExtent=True
		bUseSingleBodyPhysics=1
	End Object
	CollisionComponent=StructureMesh
	Mesh=StructureMesh
	Components.Add(StructureMesh)

	bMovable=False
	CollisionType=COLLIDE_BlockAll
	bCollideActors=True
	bBlockActors=True

	Team=0
	Health=1000
	HealthMax=1000
}
