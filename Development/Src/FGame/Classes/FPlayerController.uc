/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPlayerController extends UDKPlayerController
	dependson(FMapInfo);

var float CommanderCameraSpeed;

// Structure placement
var FStructureInfo PlacingStructureInfo;
var FStructurePreview PlacingStructurePreview;

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCaptureLocation;
var Rotator MinimapCaptureRotation;

replication
{
	if (bNetDirty)
		PlacingStructureInfo, PlacingStructurePreview;
}

simulated event PostBeginPlay()
{
	local FMapInfo MapInfo;

	Super.PostBeginPlay();

	MapInfo = FMapInfo(WorldInfo.GetMapInfo());
	if (MapInfo != None && WorldInfo.NetMode != NM_DedicatedServer) // Create minimap capture component on clients
	{
		MinimapCaptureComponent = new(Self) class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'Factions_Assets.minimap_render_texture', 90,, 0);
		MinimapCaptureComponent.bUpdateMatrices = False;
		AttachComponent(MinimapCaptureComponent);

		MinimapCaptureLocation.X = MapInfo.MapCenter.X;
		MinimapCaptureLocation.Y = MapInfo.MapCenter.Y;
		MinimapCaptureLocation.Z = MapInfo.MapRadius;
	}
}

simulated event PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);

	// Update minimap capture position
	if (MinimapCaptureComponent != None)
		MinimapCaptureComponent.SetView(MinimapCaptureLocation, MinimapCaptureRotation);
}

reliable server function ServerSpawnVehicle(name ChassisName)
{
	local FStructure_VehicleFactory VF;

	VF = FStructure_VehicleFactory(Pawn.Base);
	if (VF != None)
		VF.BuildVehicle(ChassisName, Pawn);
}

// Structure placement

reliable server function ServerBeginStructurePlacement(name StructureName)
{
	PlacingStructureInfo = FMapInfo(WorldInfo.GetMapInfo()).GetStructureInfo(StructureName);

	if (PlacingStructurePreview != None)
		PlacingStructurePreview.Destroy();

	PlacingStructurePreview = Spawn(class'FStructurePreview',,,, rot(0, 0, 0),, True);
	PlacingStructurePreview.StructureInfo = PlacingStructureInfo;
	PlacingStructurePreview.Initialize();
}

unreliable server function ServerUpdateStructurePlacement(Vector NewLocation)
{
	if (PlacingStructurePreview != None)
		PlacingStructurePreview.SetLocation(NewLocation);
}

reliable server function ServerPlaceStructure()
{
	local FStructure SpawnedStructure;

	//@todo Check to make sure player is commander

	SpawnedStructure = Spawn(PlacingStructureInfo.Archetype.Class, Self,, PlacingStructurePreview.Location, rot(0,0,0), PlacingStructureInfo.Archetype, True);
	SpawnedStructure.Team = PlayerReplicationInfo.Team.TeamIndex;

	EndStructurePlacement();
}

function EndStructurePlacement()
{
	PlacingStructureInfo.Name = '';
	PlacingStructureInfo.Archetype = None;
	if (PlacingStructurePreview != None)
		PlacingStructurePreview.Destroy();
}

// Commander view

unreliable server function ServerSetCommanderLocation(Vector NewLoc)
{
	// This function is not supposed to be called globally, so move the client to the correct state
	ClientGotoState(GetStateName());
	ClientSetViewTarget(GetViewTarget());
}

reliable server function ServerToggleCommandView()
{
	if (PlayerReplicationInfo.Team != None) // Only enter command view when on a team
		GotoState('Commanding');
}

// Exec functions

exec function ReloadWeapon()
{
	local FWeapon PlayerWeapon;

	if (Pawn != None && Pawn.Weapon != None)
	{
		PlayerWeapon = FWeapon(Pawn.Weapon);
		if (PlayerWeapon != None && (PlayerWeapon.Magazine == None || PlayerWeapon.AmmoCount != PlayerWeapon.Magazine.AmmoCountMax))
			FWeapon(Pawn.Weapon).ServerReload();
	}
	else
	{
		`log("Failed to find weapon to reload!");
	}
}

exec function BuildVehicle(name ChassisName)
{
	ServerSpawnVehicle(ChassisName);
}

exec function ToggleCommandView()
{
	ServerToggleCommandView();
}

simulated state Commanding
{
	simulated event BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;

		// Set commander view location and rotation
		ViewLocation.X = Pawn.Location.X - 2048;
		ViewLocation.Y = Pawn.Location.Y;
		ViewLocation.Z = Pawn.Location.Z + 2048;
		SetLocation(ViewLocation);
		SetRotation(Rotator(Pawn.Location - ViewLocation));

		// Set client state if dedicated server
		if (WorldInfo.NetMode == NM_DedicatedServer)
			ClientGotoState(GetStateName());
		else // Open commander HUD if client
			FHUD(myHUD).GFxCommanderHUD.Start();
	}

	simulated event EndState(name NextStateName)
	{
		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			EndStructurePlacement();
			ClientGotoState(GetStateName());
		}
		else
		{
			FHUD(myHUD).GFxCommanderHUD.Close(False);
		}
	}

	simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		// Set view point to controller location and rotation
		out_Location = Location;
		out_Rotation = Rotation;
	}

	function PlayerMove(float DeltaTime)
	{
		Velocity = Normal(PlayerInput.aForward * vect(1,0,0) + PlayerInput.aStrafe * vect(0,1,0) + PlayerInput.aUp * vect(0,0,1));

		if (Role < ROLE_Authority)
			ReplicateMove(DeltaTime, Velocity, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Velocity, DCLICK_None, rot(0,0,0));
	}

	function ProcessMove(float DeltaTime, Vector NewVelocity, EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		MoveSmooth((1 + bRun) * NewVelocity * CommanderCameraSpeed);
	}

	function ReplicateMove(float DeltaTime, Vector NewVelocity, EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		ProcessMove(DeltaTime, NewVelocity, DoubleClickMove, DeltaRot);
		ServerSetCommanderLocation(Location); // Client has authority for commander view

		if (PlayerCamera != None && PlayerCamera.bUseClientSideCameraUpdates)
			PlayerCamera.bShouldSendClientSideCameraUpdate = True;
	}

	unreliable server function ServerSetCommanderLocation(Vector NewLoc)
	{
		SetLocation(NewLoc);
	}

	reliable server function ServerToggleCommandView()
	{
		GotoState('PlayerWalking');
	}

	exec function StartFire(optional byte FireModeNum)
	{
		FHUD(myHUD).BeginDragging();

		if (PlacingStructureInfo.Name != '')
			ServerPlaceStructure();
	}

	exec function StopFire(optional byte FireModeNum)
	{
		FHUD(myHUD).EndDragging();
	}

	exec function SelectStructure(name StructureName)
	{
		ServerBeginStructurePlacement(StructureName);
	}
}

defaultproperties
{
	InputClass=class'FGame.FPlayerInput'
	CommanderCameraSpeed=30.0
	SpectatorCameraSpeed=5000.0
	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0)
}