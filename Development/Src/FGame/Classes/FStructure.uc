/**
 * Structures are stationary units that belong to a team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure extends Vehicle
	perobjectlocalized
	notplaceable;

var() bool bPermanent; // If the structure goes back to preview state when dead
var() repnotify name CurrentState;
var() repnotify byte Team; // Team index
var() int ResourceCost;
var array<MaterialInterface> OriginalMaterials;

var protected bool bPlaceable; // Internal variable to show if this FStructure can be placed on its world location during last player's tick

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
function bool Died(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		if (bPermanent)
		{
			Team = class'FTeamGame'.const.TEAM_NONE;
			GotoState('Preview');
		}
		else
		{
			GotoState('DyingStructure');
		}

		return True;
	}

	return False;
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

/**
* Check to see if the FStructure is:
* 1. On a relatively flat ground 
* 2. Obstructed by other Pawn(s)
* And swap the structure's material to reflect if it is currently placeable
*/
simulated function bool checkPlaceable()
{
	return True;
}

// Structure is being placed
auto simulated state Placing
{
	ignores TakeDamage;

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
	simulated function bool checkPlaceable()
	{
		local float SampleDistanceX, SampleDistanceY, LongerSide;
		local int SampleDensity, PermittedHeightRange, i, j, OverlappingCount;
		local vector SamplingStartPoint, CurrentTraceLineStart, CurrentTraceLineEnd, HitLocation, HitNormal, RotX,RotY,RotZ;
		local actor HitActor, OverlappedActor;
		local bool bWasPlaceable, bNowPlaceable;

		// Rotation of the structure should be taken into consideration when checking the structure's placement		
		GetAxes(Rotation,RotX,RotY,RotZ);

		// Sample trace line density used for flat ground sampling
		// e.g. SampleDensity = 10;   10*10 trace lines will be used
		// In general, the higher the density, the more accurate the result but the worse the performance is
		SampleDensity = 10;
		
		// The larger the PermittedHeightRange, the less strict the flat ground checking is
		PermittedHeightRange = 10;

		// Distance between each trace line on XY plane
		// Calculated based on the SampleDensity
		// Note that Mesh's bounding box's size will be used to determine where the sampling trace lines should lie on
		SampleDistanceX = Mesh.Bounds.BoxExtent.X/SampleDensity;
		SampleDistanceY = Mesh.Bounds.BoxExtent.Y/SampleDensity;

		// The Location variable is the position of the center of the mesh in the world
		// We want to start sampling from the top left hand corner (XY Plane), all the way down to the bottom right hand corner
		SamplingStartPoint = Location - RotX*(Mesh.Bounds.BoxExtent.X/2);
		SamplingStartPoint = Location - RotY*(Mesh.Bounds.BoxExtent.Y/2);
				
		
		// DO NOT use FStructure Class's bPlaceable to store intermediate values
		// It is to make this function thread safe
		bWasPlaceable = bPlaceable;
		bNowPlaceable = True;		


		// This is the double loop for flat ground check sampling. 
		// 
		// Take SampleDensity = 10; as an example,
		// 10*10 sampling trace line are distributed on the XY Plane
		//
		// Loop through each of the 10*10 trace lines, see if the trace line hit the terrain within the PermittedHeightRange
		i = 0;
		do
		{
			j = 0;
			do
			{
				// Set the current sampling trace line's start point
				CurrentTraceLineStart = SamplingStartPoint + RotX * (SampleDistanceX * i);
				CurrentTraceLineStart = SamplingStartPoint + RotY * (SampleDistanceY * j);
				CurrentTraceLineStart.Z = Location.Z + PermittedHeightRange;

				// Set the current sampling trace line's end point
				CurrentTraceLineEnd.X = CurrentTraceLineStart.X;
				CurrentTraceLineEnd.Y = CurrentTraceLineStart.Y;
				CurrentTraceLineEnd.Z = Location.Z - PermittedHeightRange;

				// Start tracing
				HitActor = Trace(HitLocation,HitNormal,CurrentTraceLineEnd,CurrentTraceLineStart,False,vect(2,2,2));

				// If we cannot find the terrain within the PermittedHeightRange,
				// we should not allow this FStructure to be placed
				if (HitActor == None || !HitActor.IsA('Landscape'))
					bNowPlaceable = False;

				j++;
			} until (j >= SampleDensity || !bNowPlaceable);
			i++;
		} until (i >= SampleDensity || !bNowPlaceable);






		// Use the longest extent of the bounding box as the radius
		// To check if this FStructure overlapps with other non-terrain Actor(s)
		if (Mesh.Bounds.BoxExtent.X > Mesh.Bounds.BoxExtent.Y)
			LongerSide = Mesh.Bounds.BoxExtent.X;
		else
			LongerSide = Mesh.Bounds.BoxExtent.Y;

		foreach OverlappingActors(class'Actor', OverlappedActor, LongerSide,,True)
		{
			if (OverlappedActor.IsA('Pawn')) //|| OverlappedActor.IsA('StaticMeshActor'))
				OverlappingCount++;
		}		
						
		// If overlapping occurs,
		// we should not allow this FStructure to be placed
		if (OverlappingCount > 0)
			bNowPlaceable = False;		
		



		// Switch between different materials to show if this FStructure is currently placeable
		// i.e. The structure should be green in color if it is placeable, red in color if it is not placeable
		if (bNowPlaceable)
		{
			if (!bWasPlaceable)
			{
				for (i = 0; i < Mesh.GetNumElements(); i++)
					Mesh.SetMaterial(i, Material'Factions_Assets.Materials.StructurePreviewMaterial');
			}
		}
		else
		{
			if (bWasPlaceable)
			{
				for (i = 0; i < Mesh.GetNumElements(); i++)
					Mesh.SetMaterial(i, Material'Factions_Assets.Materials.StructurePreviewMaterialNotPlaceable');
			}			
		}		

		bPlaceable = bNowPlaceable;
		return bPlaceable;
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
	ignores TakeDamage;

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

			if (Health > HealthMax / 4)
			{
				GotoState('Active');
			}
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

		// Set mapper placed-structures to full health
		if (PreviousStateName == '')
		{
			Health = HealthMax;
		}

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

// Structure has been destroyed
simulated state DyingStructure
{
	ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon);
	simulated function PlayNextAnimation();
	singular event BaseChange();
	event Landed(vector HitNormal, Actor FloorActor);
	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);
	simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);
	simulated function BlowupVehicle();

	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Global.BeginState(PreviousStateName);

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			Mesh.SetMaterial(0, Material'Factions_Assets.Materials.UnitDestroyedMaterial');
		}
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

	TickGroup=TG_PostAsyncWork
	CollisionType=COLLIDE_BlockAll
	bCollideActors=True
	bBlockActors=True
	bCollideWorld=False
	bAlwaysRelevant=True
	bPlaceable=True

	Team=255 // class'FTeamGame'.const.TEAM_NONE
	Health=1
	HealthMax=1000
}
