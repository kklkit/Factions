/**
 * Structures are stationary units that belong to a team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure extends Vehicle
	perobjectlocalized
	notplaceable;

var() repnotify name CurrentState;
var() repnotify byte Team; // Team index
var() int ResourceCost;
var array<MaterialInterface> OriginalMaterials;

replication
{
	if (bNetDirty)
		CurrentState, Team;
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'CurrentState')
		GotoState(CurrentState);

	Super.ReplicatedEvent(VarName);
}

/**
 * @extends
 */
simulated event SetInitialState()
{
	InitialState = CurrentState;

	Super.SetInitialState();
}

/**
 * @extends
 */
simulated event BeginState(name PreviousStateName)
{
	Super.BeginState(PreviousStateName);

	if (Role == ROLE_Authority)
		CurrentState = GetStateName();
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

/**
 * Puts the structure in a preview state.
 */
simulated function SetupPreview()
{
	local int i;

	Mesh.SetBlockRigidBody(False);
	Mesh.SetActorCollision(False, False);
	Mesh.SetTraceBlocking(False, False);
	Mesh.SetRBChannel(RBCC_Nothing);
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

/**
 * @extends
 */
function SetMovementPhysics();

/**
 * Structures must have a CurrentState set.
 * 
 * @extends
 */
function bool CheckForErrors()
{
	if (CurrentState == '')
	{
		`log(Self @ "has no CurrentState!");
		return true;
	}

	return Super.CheckForErrors();
}

/**
 *  Hide all placing mesh for non-commander players
 */
simulated function HidePlacingStructurePreview()
{
	if (GetALocalPlayerController().GetStateName()!='Commanding' && Team!=class'FTeamGame'.const.TEAM_NONE)
		Mesh.SetHidden(true);
}

/**
 *
 */
simulated function UnhideFriendlyStructurePreview(int TeamIndex)
{
	if(Mesh.HiddenGame && Team == TeamIndex) Mesh.SetHidden(false);
}

// Structure is being placed
auto simulated state Placing
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Global.BeginState(PreviousStateName);

		if (PreviousStateName != 'Preview')
			SetupPreview();

		SetCollisionType(COLLIDE_NoCollision);
	}

	simulated event ReplicatedEvent(name VarName)
	{
		if (VarName == 'Team')
			HidePlacingStructurePreview();
			Super.ReplicatedEvent(VarName);
	}
}

// Structure is placed and is waiting to be built
simulated state Preview
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Global.BeginState(PreviousStateName);

		if (PreviousStateName != 'Placing')
			SetupPreview();

		SetCollisionType(COLLIDE_TouchWeapons);

		// Unhide friendly preview hidden mesh after being placed
		UnhideFriendlyStructurePreview(GetALocalPlayerController().GetTeamNum());
	}

	/**
	 * @extends
	 */
	event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
	{
		if (Team == class'FTeamGame'.const.TEAM_NONE)
			Team = Healer.GetTeamNum();
		else if (Team == Healer.GetTeamNum())  // To build/heal the structure, healer must be the owner team of the structure
		{
			Health = Min(HealthMax, Health + Amount);
			GotoState('Active');
		}
	
		return True;
	}
}

// Structure has been built
simulated state Active
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

		if (Mesh.HiddenGame) Mesh.SetHidden(false); 
		// Unhide the mesh if it is hidden because of being an enemy team's preview mesh
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

	Team=255 // class'FTeamGame'.const.TEAM_NONE
	Health=1
	HealthMax=1000
}
