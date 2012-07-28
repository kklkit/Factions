/**
 * Player controller class.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPlayerController extends UDKPlayerController;

const MaxLoadoutSlots=4;

// Input
var Vector LastMouseWorldLocation;
var bool bIsFiring;

// Commander
var name StateBeforeCommanding;
var float CommanderCameraSpeed;
var int CommanderCameraZoom, CommanderCameraMinZoom, CommanderCameraMaxZoom;

// Structure placement
var FStructure PlacingStructure;
var Vector NextPlacingStructureLocation;
var Rotator NextPlacingStructureRotation;

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCaptureLocation;
var Rotator MinimapCaptureRotation;

// Inventory
var FInfantryClass CurrentInfantryClassArchetype;
var FWeapon CurrentWeaponArchetypes[MaxLoadoutSlots];

replication
{
	if (bNetDirty)
		PlacingStructure;

	if (bNetOwner)
		CurrentInfantryClassArchetype, CurrentWeaponArchetypes;
}

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Create the minimap capture component on clients only
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MinimapCaptureComponent = new(Self) class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'Factions_Assets.minimap_render_texture', 1,, 0);
		MinimapCaptureComponent.bUpdateMatrices = False; // Minimap camera is controlled by game code
		AttachComponent(MinimapCaptureComponent);
	}
}

/**
 * @extends
 */
simulated event PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);

	MinimapCaptureLocation = FMapInfo(WorldInfo.GetMapInfo()).MapOrigin;

	// Update minimap capture position
	if (MinimapCaptureComponent != None)
	{
		MinimapCaptureComponent.SetView(MinimapCaptureLocation, MinimapCaptureRotation);
	}

	// Send the structure placement location to the server only if it has changed
	if (PlacingStructure != None)
	{
		if (PlacingStructure.Location != NextPlacingStructureLocation)
		{
			ServerUpdateStructureLocation(NextPlacingStructureLocation);
		}

		if (PlacingStructure.Rotation != NextPlacingStructureRotation)
		{
			ServerUpdateStructureRotation(NextPlacingStructureRotation);
		}
	}
}

/**
 * @extends
 */
function CheckJumpOrDuck()
{
	if (Pawn == None)
		return;

	if (bPressedJump)
		Pawn.DoJump(bUpdating);

	if (Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch)
		Pawn.ShouldCrouch(bDuck != 0);
}

/**
 * @extends
 */
reliable server function ServerChangeTeam(int N)
{
	local TeamInfo OldTeam;
	local Pawn OldPawn;

	OldTeam = PlayerReplicationInfo.Team;
	OldPawn = Pawn;

	WorldInfo.Game.ChangeTeam(Self, N, True);

	// Only signal player changed team if not changing from spectator
	if (WorldInfo.Game.bTeamGame && OldTeam != None && PlayerReplicationInfo.Team != OldTeam)
	{
		// If switching to spectator, the pawn will not exist
		if (Pawn != None)
		{
			Pawn.PlayerChangedTeam();
		}
		else
		{
			OldPawn.PlayerChangedTeam();
		}
	}
}

/**
 * Spawns a vehicle for the player.
 */
reliable server function ServerSpawnVehicle(FVehicle VehicleArchetype, FVehicleWeapon VehicleWeaponArchetype1, FVehicleWeapon VehicleWeaponArchetype2)
{
	local array<FVehicleWeapon> VehicleWeaponArchetypes;

	VehicleWeaponArchetypes.AddItem(VehicleWeaponArchetype1);
	VehicleWeaponArchetypes.AddItem(VehicleWeaponArchetype2);

	BuildVehicle(VehicleArchetype, VehicleWeaponArchetypes);
}

/**
 * Builds a vehicle at the vehicle factory the player is standing on.
 */
function BuildVehicle(FVehicle VehicleArchetype, array<FVehicleWeapon> VehicleWeaponArchetypes)
{
	local FStructure_VehicleFactory VF;

	// Get the vehicle factory the player is standing on
	VF = FStructure_VehicleFactory(Pawn.Base);
	if (VF != None)
		VF.BuildVehicle(Self, VehicleArchetype, VehicleWeaponArchetypes);
}

/**
 * Packs the weapon arguments into an array and calls SetLoadout.
 */
reliable server function ServerSetLoadout(FInfantryClass InfantryClassArchetype, FWeapon WeaponArchetype1, FWeapon WeaponArchetype2, FWeapon WeaponArchetype3, FWeapon WeaponArchetype4)
{
	local FWeapon WeaponArchetypes[4];

	WeaponArchetypes[0] = WeaponArchetype1;
	WeaponArchetypes[1] = WeaponArchetype2;
	WeaponArchetypes[2] = WeaponArchetype3;
	WeaponArchetypes[3] = WeaponArchetype4;

	SetLoadout(InfantryClassArchetype, WeaponArchetypes);
}

/**
 * Sets and equips the player's loadout.
 */
function SetLoadout(FInfantryClass InfantryClassArchetype, FWeapon WeaponArchetypes[MaxLoadoutSlots])
{
	local int i;

	// Set the current class
	CurrentInfantryClassArchetype = InfantryClassArchetype;

	// Set the current weapons
	for (i = 0; i < MaxLoadoutSlots; i++)
	{
		if (WeaponArchetypes[i] != None && WeaponArchetypes[i].WeaponClassArchetype == CurrentInfantryClassArchetype.LoadoutSlots[i])
		{
			CurrentWeaponArchetypes[i] = WeaponArchetypes[i];
		}
		else // No equipment in the slot
		{
			CurrentWeaponArchetypes[i] = None;
		}
	}

	// Equip loadout
	if (Pawn != None)
		Pawn.AddDefaultInventory();
}

/**
 * Called when team player count changes (used to update GUI).
 */
reliable client function ClientNotifyTeamCountChanged()
{
	if (myHUD != None)
		FHUD(myHUD).GFxOmniMenu.Invalidate("team");
}

// Structure placement

/**
 * Begins structure placement.
 */
reliable server function ServerBeginStructurePlacement(byte StructureIndex, Vector WorldLocation)
{
	local FStructure PlacingStructureArchetype;

	PlacingStructureArchetype = FMapInfo(WorldInfo.GetMapInfo()).Structures[StructureIndex];

	// Remove the old structure preview if it exists
	if (PlacingStructure != None)
		PlacingStructure.Destroy();

	// Spawn a structure preview for the requested structure
	PlacingStructure = Spawn(PlacingStructureArchetype.Class, Self,, WorldLocation, rot(0,0,0), PlacingStructureArchetype, True);
	PlacingStructure.Team = GetTeamNum();
}

/**
 * Updates the location of the current structure preview.
 */
unreliable server function ServerUpdateStructureLocation(Vector NewLocation)
{
	if (PlacingStructure != None)
	{
		PlacingStructure.SetLocation(NewLocation);
	}
}

/**
 * Updates the rotation of the current structure preview.
 */
unreliable server function ServerUpdateStructureRotation(Rotator NewRotation)
{
	if (PlacingStructure != None)
	{
		NewRotation.Pitch = 0; // Structure should always be flat to ground
		PlacingStructure.SetRotation(NewRotation);
	}
}

/**
 * Spawns the requested structure at the location of the structure preview.
 */
reliable server function ServerPlaceStructure()
{
	if (FTeamInfo(PlayerReplicationInfo.Team).Resources >= PlacingStructure.ResourceCost)
	{
		if (PlacingStructure.checkPlaceable())
		{
			FTeamInfo(PlayerReplicationInfo.Team).Resources -= PlacingStructure.ResourceCost;
			PlacingStructure.GotoState('Preview');
			EndStructurePlacement();
		}
		else
			`log("Unable to place structure at required location" @ PlacingStructure);
	}
	else
		`log("Not enough resources to place" @ PlacingStructure);
}

/**
 * Clears the placing structure info and deletes the structure preview.
 * 
 * This should always be called when exiting structure placement mode.
 */
function EndStructurePlacement()
{
	if (PlacingStructure != None && PlacingStructure.IsInState('Placing'))
	{
		PlacingStructure.Destroy();
	}

	PlacingStructure = None;
}

// Commander view

/**
 * Stub function for the one in the commander state.
 */
unreliable server function ServerSetCommanderLocation(Vector NewLoc)
{
	// This function is not supposed to be called globally, so move the client to the correct state
	ClientGotoState(GetStateName());
	ClientSetViewTarget(GetViewTarget());
}

/**
 * Enters the command view.
 */
reliable server function ServerToggleCommandView()
{
	if (PlayerReplicationInfo.Team != None && Pawn != None && FVehicle(Pawn) != None && FVehicle(Pawn).bIsCommandVehicle)
		GotoState('Commanding');
}

// Exec functions

/**
 * Reloads the current player's weapon
 */
exec function ReloadWeapon()
{
	local FWeapon PlayerWeapon;

	if (Pawn != None && Pawn.Weapon != None)
	{
		PlayerWeapon = FWeapon(Pawn.Weapon);

		// Only reload if the weapon's ammo is not already full (prevents wasted magazines)
		if (PlayerWeapon != None && FWeapon_Firearm(PlayerWeapon) != None && PlayerWeapon.AmmoCount != PlayerWeapon.MaxAmmoCount)
			FWeapon_Firearm(PlayerWeapon).ServerReload();
	}
	else
	{
		`log("Failed to find weapon to reload!");
	}
}

/**
 * Toggles command view mode.
 */
exec function ToggleCommandView()
{
	ServerToggleCommandView();
}

/**
 * @extends
 */
exec function Talk()
{
	FHUD(myHUD).GFxChat.OpenChat('all');
}

/**
 * @extends
 */
exec function TeamTalk()
{
	FHUD(myHUD).GFxChat.OpenChat('team');
}

state PlayerDriving
{
	/**
	 * @extends
	 */
	function UpdateRotation(float DeltaTime)
	{
		local Rotator InputRotation;

		Super.UpdateRotation(DeltaTime);

		// Rotate vehicle turret
		if (FVehicle(Pawn) != None)
		{
			InputRotation.Yaw = PlayerInput.aTurn;
			InputRotation.Pitch = PlayerInput.aLookUp;
			FVehicle(Pawn).RotateTurret(0, InputRotation);
		}
	}
}

simulated state Commanding
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;
		local Rotator ViewRotation;

		StateBeforeCommanding = PreviousStateName;

		// If not driving a vehicle
		if (Vehicle(Pawn) == None)
		{
			// Stop pawn inputs
			Pawn.Acceleration = vect(0,0,0);
		}
		else
		{
			// Stop vehicle inputs
			Vehicle(Pawn).SetInputs(0, 0, 0);
		}

		// Set commander view location and rotation
		ViewLocation.X = Pawn.Location.X;
		ViewLocation.Y = Pawn.Location.Y;
		ViewLocation.Z = Pawn.Location.Z;
		ViewRotation.Pitch = -8000;

		SetLocation(ViewLocation);
		SetRotation(ViewRotation);

		if (WorldInfo.NetMode == NM_DedicatedServer)
			ClientGotoState(GetStateName());

		if (myHUD != None)
			FHUD(myHUD).GFxCommanderHUD.Start();
	}

	/**
	 * @extends
	 */
	simulated event EndState(name NextStateName)
	{
		if (Role == ROLE_Authority)
			EndStructurePlacement();

		if (WorldInfo.NetMode == NM_DedicatedServer)
			ClientGotoState(GetStateName());

		if (myHUD != None)
			FHUD(myHUD).GFxCommanderHUD.Close(False);
	}

	/**
	 * @extends
	 */
	simulated event PlayerTick(float DeltaTime)
	{
		local bool bNeedPlaceableCheck;
		bNeedPlaceableCheck = False;

		// Update the placing structure location
		if (PlacingStructure != None)
		{
			bNeedPlaceableCheck = (NextPlacingStructureLocation != LastMouseWorldLocation);

			if (!bIsFiring)
				NextPlacingStructureLocation = LastMouseWorldLocation;
			else
				NextPlacingStructureRotation = Rotator(LastMouseWorldLocation - PlacingStructure.Location);			
		}

		Global.PlayerTick(DeltaTime);

		if (bNeedPlaceableCheck)
			PlacingStructure.checkPlaceable();
	}

	/**
	 * @extends
	 */
	simulated event DrawHUD(HUD H)
	{
		local Vector HitLocation, HitNormal, WorldOrigin, WorldDirection;

		// Set the last mouse world location
		if (LocalPlayer(Player).ViewportClient.bDisplayHardwareMouseCursor)
		{
			H.Canvas.DeProject(LocalPlayer(Player).ViewportClient.GetMousePosition(), WorldOrigin, WorldDirection);
			Trace(HitLocation, HitNormal, WorldOrigin + WorldDirection * 65536.0, WorldOrigin, False,,,);
			LastMouseWorldLocation = HitLocation;
		}
	}

	/**
	 * @extends
	 */
	simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		local vector CamDir, HitLocation, CamStart, HitNormal, CamRotX, CamRotY, CamRotZ;
		local actor HitActor;
		
		Global.GetPlayerViewPoint(out_Location,out_Rotation);
		CamStart = Location;

		CommanderCameraZoom = Max(CommanderCameraMinZoom, CommanderCameraZoom);
		CommanderCameraZoom = Min(CommanderCameraMaxZoom, CommanderCameraZoom);

				
		GetAxes(out_Rotation, CamRotX, CamRotY, CamRotZ);
		CamDir = CamRotX * -CommanderCameraZoom;
		out_Location = CamDir+CamStart;		

		// Trace to see if the camera is going through the terrain
		HitActor = Trace(HitLocation, HitNormal, out_Location, CamStart, false, vect(12, 12, 12));
		
		if ( HitActor != None && HitActor.IsA('Landscape'))
			out_Location = HitLocation;
		

		out_Rotation = Rotation;
	}

	/**
	 * @extends
	 */
	function PlayerMove(float DeltaTime)
	{
		local vector CamRotX, CamRotY, CamRotZ;
		local vector ForwardVector;
		GetAxes(Rotation,CamRotX, CamRotY, CamRotZ);

		ForwardVector.X = CamRotY.Y;
		ForwardVector.Y = -CamRotY.X;
		ForwardVector.Z = CamRotY.Z;

		// Get the player inputs
		Velocity = Normal(PlayerInput.aForward * ForwardVector + PlayerInput.aStrafe * CamRotY + PlayerInput.aUp * vect(0,0,1));

		if (Role < ROLE_Authority)
			// Simulate the movement on clients
			ReplicateMove(DeltaTime, Velocity, DCLICK_None, rot(0,0,0));
		else
			// Execute the actual movement on the server
			ProcessMove(DeltaTime, Velocity, DCLICK_None, rot(0,0,0));
	}

	/**
	 * @extends
	 */
	function ProcessMove(float DeltaTime, Vector NewVelocity, EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		// Move in the direction of the player's input
		MoveSmooth((1 + bRun) * NewVelocity * CommanderCameraSpeed);
	}

	/**
	 * @extends
	 */
	function ReplicateMove(float DeltaTime, Vector NewVelocity, EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		ProcessMove(DeltaTime, NewVelocity, DoubleClickMove, DeltaRot);

		// Client has authority for commander view
		ServerSetCommanderLocation(Location);

		if (PlayerCamera != None && PlayerCamera.bUseClientSideCameraUpdates)
			PlayerCamera.bShouldSendClientSideCameraUpdate = True;
	}

	/**
	 * Sets the location of the player controller.
	 * 
	 * Used by the client to specify where the command view is.
	 */
	unreliable server function ServerSetCommanderLocation(Vector NewLoc)
	{
		SetLocation(NewLoc);
	}

	/**
	 * Exit the command view.
	 */
	reliable server function ServerToggleCommandView()
	{
		GotoState(StateBeforeCommanding);
	}

	/**
	 * @extends
	 */
	exec function StartFire(optional byte FireModeNum)
	{
		bIsFiring = True;
	}

	/**
	 * @extends
	 */
	exec function StopFire(optional byte FireModeNum)
	{
		bIsFiring = False;

		// Place the structure if in structure placement mode
		if (PlacingStructure != None)
			ServerPlaceStructure();
	}

	/**
	 * Enters structure placement mode.
	 */
	exec function SelectStructure(byte StructureIndex)
	{
		ServerBeginStructurePlacement(StructureIndex, LastMouseWorldLocation);
	}	

	/**
	 * Toggle commander view rotation
	 */
	exec function ToggleCommandViewRotation(bool bNowOn)
	{
		if (bNowOn)
		{
			FHUD(myHUD).GFxCommanderHUD.bCaptureMouseInput = False;
			FHUD(myHUD).GFxCommanderHUD.bCaptureInput = False;
			FHUD(myHUD).GFxCommanderHUD.SetHardwareMouseCursorVisibility(False);
			PushState('RotatingCommandView');
		}
	}

	exec function CommandViewZoomIn()
	{
		CommanderCameraZoom -= 100;
	}

	exec function CommandViewZoomOut()
	{
		CommanderCameraZoom += 100;
	}
}

simulated state RotatingCommandView extends Commanding
{
	function PlayerMove( float DeltaTime )
	{
		Super.PlayerMove(DeltaTime);

		// update 'looking' rotation
		UpdateRotation(DeltaTime);
		bPressedJump = false;		
	}

	/**
	 * Toggle commander view rotation
	 */
	exec function ToggleCommandViewRotation(bool bNowOn)
	{
		if (!bNowOn)
		{
			// FHUD(myHUD).GFxCommanderHUD.bCaptureMouseInput = True;
			FHUD(myHUD).GFxCommanderHUD.SetHardwareMouseCursorVisibility(True);
			PopState();
		}
	}
}

defaultproperties
{
	InputClass=class'FGame.FPlayerInput'

	DesiredFOV=90.0
	DefaultFOV=90.0
	FOVAngle=90.0
	bCheckSoundOcclusion=True
	VehicleCheckRadiusScaling=1.0
	PulseTimer=5.0
	MinRespawnDelay=1.5

	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0)

	CommanderCameraSpeed=75.0
	SpectatorCameraSpeed=5000.0

	CommanderCameraZoom=2048
	CommanderCameraMinZoom=1500
	CommanderCameraMaxZoom=10000
}