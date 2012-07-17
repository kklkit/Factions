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
 *  Hide the structure mesh from non-commander players and enemy players.
 */
simulated function HidePlacingStructurePreview()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && (!GetALocalPlayerController().IsInState('Commanding') ||
		(!WorldInfo.GRI.OnSameTeam(Self, GetALocalPlayerController()) && Team != class'FTeamGame'.const.TEAM_NONE)))
	{
		Mesh.SetHidden(True);
	}
}

/**
 * Hide the structure mesh if being viewed by opposing team.
 */
simulated function HideEnemyStructurePreview()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && !WorldInfo.GRI.OnSameTeam(Self, GetALocalPlayerController()) && Team != class'FTeamGame'.const.TEAM_NONE)
	{
		Mesh.SetHidden(True);
	}
}

/**
 * Show the structure mesh if being viewed by same team.
 */
simulated function UnhideFriendlyStructurePreview()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh.HiddenGame && WorldInfo.GRI.OnSameTeam(Self, GetALocalPlayerController()))
	{
		Mesh.SetHidden(False);
	}
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

	/**
	 * @extends
	 */
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
		UnhideFriendlyStructurePreview();
	}

	/**
	 * @extends
	 */
	event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
	{
		// Set structure team to the builder
		if (Team == class'FTeamGame'.const.TEAM_NONE)
		{
			Team = Healer.GetTeamNum();
		}

		// To build/heal the structure, healer must be the owner team of the structure
		if (WorldInfo.GRI.OnSameTeam(Self, Healer))
		{
			Health = Min(HealthMax, Health + Amount);
			GotoState('Active');
		}
	
		return True;
	}

	/**
	 * @extends
	 */
	simulated function NotifyLocalPlayerTeamReceived()
	{
		Super.NotifyLocalPlayerTeamReceived();

		HideEnemyStructurePreview();
		UnhideFriendlyStructurePreview();
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

		// All hidden structure mesh should be visible when built
		if (Mesh.HiddenGame)
			Mesh.SetHidden(False); 		
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
