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
		Mesh.SetBlockRigidBody(False);
		Mesh.SetActorCollision(False, False);
		SetCollisionType(COLLIDE_NoCollision);
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
		Mesh.SetBlockRigidBody(True);
		Mesh.SetActorCollision(True, True);
		SetCollisionType(COLLIDE_BlockAll);
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
