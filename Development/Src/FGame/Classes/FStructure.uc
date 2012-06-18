/**
 * Structures are stationary units that belong to a team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure extends Vehicle
	perobjectlocalized
	notplaceable;

// Team index
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
simulated event SetInitialState()
{
	// Hack: Fully build structures placed by the mapper
	if (WorldInfo.bStartup)
		InitialState = 'StructureActive';

	Super.SetInitialState();
}

/**
 * @extends
 */
simulated event byte ScriptGetTeamNum()
{
	return Team;
}

/**
 * Sets the object on the client to the given state.
 */
reliable client function ClientGotoState(name NewState, optional name NewLabel)
{
	if ((NewLabel == 'Begin' || NewLabel == '') && !IsInState(NewState))
	{
		GotoState(NewState);
	}
	else
	{
		GotoState(NewState, NewLabel);
	}
}

// Structure has not yet been built
auto simulated state() StructurePreview
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		Mesh.SetBlockRigidBody(False);
		Mesh.SetActorCollision(False, False);
		Mesh.SetTraceBlocking(False, False);
		Mesh.SetRBChannel(RBCC_Nothing);
		SetCollisionType(COLLIDE_NoCollision);
		SetCollision(False, False);

		ClientGotoState(GetStateName());
	}
}

// Structure has been built
simulated state() StructureActive
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		Mesh.SetBlockRigidBody(True);
		Mesh.SetActorCollision(True, True);
		Mesh.SetTraceBlocking(True, True);
		Mesh.SetRBChannel(RBCC_Vehicle);
		SetCollisionType(COLLIDE_BlockAll);
		SetCollision(True, True);

		ClientGotoState(GetStateName());
	}
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

	CollisionType=COLLIDE_BlockAll
	bCollideActors=True
	bBlockActors=True
	bCollideWorld=False
	bAlwaysRelevant=True
}
