/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPlayerController extends UDKPlayerController
	dependson(FStructureInfo);

// Commander
var() float CommanderCameraSpeed;

// Structure placement
var class<FStructure> PlacingStructureClass;
var bool bPlaceStructure; // True when the player has requested to place the structure

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCaptureLocation;
var Rotator MinimapCaptureRotation;

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

		if (WorldInfo.NetMode == NM_DedicatedServer)
			ClientGotoState(GetStateName());
		else
			FHUD(myHUD).GFxCommanderHUD.Start();
	}

	simulated event EndState(name NextStateName)
	{
		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			ClientGotoState(GetStateName());
		}
		else
		{
			bPlaceStructure = False;
			PlacingStructureClass = None;

			FHUD(myHUD).EndPreviewStructure();
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
		PlaceStructure();
	}

	exec function StopFire(optional byte FireModeNum)
	{
		FHUD(myHUD).EndDragging();
	}

	exec function SelectStructure(name StructureName)
	{
		local StructureInfo StructureInfo;

		StructureInfo = class'FStructureInfo'.default.Structures[class'FStructureInfo'.default.Structures.Find('Name', StructureName)];
		PlacingStructureClass = StructureInfo.Class;
		FHUD(myHUD).StartPreviewStructure(StructureInfo);
	}

	exec function PlaceStructure()
	{
		if (PlacingStructureClass != None)
			bPlaceStructure = True;
	}
}

simulated event PostBeginPlay()
{
	local FMapInfo MI;

	Super.PostBeginPlay();

	MI = FMapInfo(WorldInfo.GetMapInfo());
	if (MI != None && WorldInfo.NetMode != NM_DedicatedServer)
	{
		MinimapCaptureComponent = new(self) class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'Factions_Assets.minimap_render_texture', 90,, 0);
		MinimapCaptureComponent.bUpdateMatrices = False;
		AttachComponent(MinimapCaptureComponent);

		MinimapCaptureLocation.X = MI.MapCenter.X;
		MinimapCaptureLocation.Y = MI.MapCenter.Y;
		MinimapCaptureLocation.Z = MI.MapRadius;
	}
}

event PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);

	MinimapCaptureComponent.SetView(MinimapCaptureLocation, MinimapCaptureRotation);
}

simulated function SpawnStructure(Vector StructureLocation)
{
	ServerSpawnStructure(PlacingStructureClass, StructureLocation);
	bPlaceStructure = False;
	PlacingStructureClass = None;
}

reliable server function ServerSpawnVehicle(name ChassisName)
{
	local FStructure_VehicleFactory VF;

	VF = FStructure_VehicleFactory(Pawn.Base);

	if (VF != None)
		VF.BuildVehicle(ChassisName, Pawn);
}

reliable server function ServerSpawnStructure(class<FStructure> StructureClass, Vector StructureLocation)
{
	local FStructure Structure;

	Structure = Spawn(StructureClass,,, StructureLocation, rot(0,0,0),, true);
	Structure.Team = PlayerReplicationInfo.Team.TeamIndex;
}

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

defaultproperties
{
	InputClass=class'FGame.FPlayerInput'
	bPlaceStructure=False
	CommanderCameraSpeed=30.0
	SpectatorCameraSpeed=5000.0
	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0)
}