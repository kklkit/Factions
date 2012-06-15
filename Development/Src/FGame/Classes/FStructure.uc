/**
 * Base class for all structures.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure extends Vehicle
	notplaceable;

// Team index of the team this structure is on
var() byte Team;

/**
 * @extends
 */
function bool AnySeatAvailable()
{
	// Don't allow players to drive structures
	return False;
}

/**
 * @extends
 */
simulated event byte ScriptGetTeamNum()
{
	return Team;
}

// Structure has not yet been built
state StructurePreview
{
	/**
	 * @extends
	 */
	event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		Mesh.SetBlockRigidBody(False);
		Mesh.SetActorCollision(False, False);
		Mesh.SetTraceBlocking(False, False);
		Mesh.SetRBChannel(RBCC_Nothing);
		SetCollisionType(COLLIDE_NoCollision);
		SetCollision(False, False);
	}
}

// Structure has been built
auto state StructureActive
{
	/**
	 * @extends
	 */
	event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		Mesh.SetBlockRigidBody(True);
		Mesh.SetActorCollision(True, True);
		Mesh.SetTraceBlocking(True, True);
		Mesh.SetRBChannel(RBCC_Vehicle);
		SetCollisionType(COLLIDE_BlockAll);
		SetCollision(True, True);
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=UDKSkeletalMeshComponent Name=StructureMesh
		LightEnvironment=LightEnvironment0
		bUseSingleBodyPhysics=1
	End Object
	CollisionComponent=StructureMesh
	Mesh=StructureMesh
	Components.Add(StructureMesh)

	bCollideWorld=False
}
