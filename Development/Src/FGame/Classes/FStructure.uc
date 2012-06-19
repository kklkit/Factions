/**
 * Structures are stationary units that belong to a team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure extends Vehicle
	perobjectlocalized
	notplaceable;

var repnotify name CurrentStateName;

var array<MaterialInterface> OriginalMaterials;

// Team index
var() byte Team;

replication
{
	if (bNetDirty)
		CurrentStateName, Team;
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'CurrentStateName')
		GotoState(CurrentStateName);

	Super.ReplicatedEvent(VarName);
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
simulated event BeginState(name PreviousStateName)
{
	Super.BeginState(PreviousStateName);

	if (Role == ROLE_Authority)
		CurrentStateName = GetStateName();
}

/**
 * @extends
 */
simulated event byte ScriptGetTeamNum()
{
	return Team;
}

/**
 * @extends
 */
function bool AnySeatAvailable()
{
	// Don't allow players to drive structures
	return False;
}

// Structure is being placed
auto simulated state StructurePlacing
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		local int i;

		Global.BeginState(PreviousStateName);

		Mesh.SetBlockRigidBody(False);
		Mesh.SetActorCollision(False, False);
		Mesh.SetTraceBlocking(False, False);
		Mesh.SetRBChannel(RBCC_Nothing);
		SetCollisionType(COLLIDE_NoCollision);
		SetCollision(False, False);

		// Save original materials before replacing with preview materials
		if (Worldinfo.NetMode != NM_DedicatedServer)
		{
			for (i = 0; i < Mesh.GetNumElements(); i++)
			{
				OriginalMaterials[i] = Mesh.GetMaterial(i);
				Mesh.SetMaterial(i, Material'Factions_Assets.Materials.StructurePreviewMaterial');
			}
		}
	}
}

// Structure is placed and is waiting to be built
simulated state StructurePreview
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Global.BeginState(PreviousStateName);

		SetCollisionType(COLLIDE_TouchWeapons);
	}

	/**
	 * @extends
	 */
	event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
	{
		GotoState('StructureActive');
		Health = Min(HealthMax, Health + Amount);

		return True;
	}
}

// Structure has been built
simulated state StructureActive
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		local int i;

		Global.BeginState(PreviousStateName);

		Mesh.SetBlockRigidBody(True);
		Mesh.SetActorCollision(True, True);
		Mesh.SetTraceBlocking(True, True);
		Mesh.SetRBChannel(RBCC_Vehicle);
		SetCollisionType(COLLIDE_BlockAll);
		SetCollision(True, True);

		// Restore original materials
		if (Worldinfo.NetMode != NM_DedicatedServer)
			for (i = 0; i < OriginalMaterials.Length; i++)
				Mesh.SetMaterial(i, OriginalMaterials[i]);
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

	Health=1
	HealthMax=1000
}
