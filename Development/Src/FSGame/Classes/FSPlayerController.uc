/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

// Commander
var() float CommanderCameraSpeed;
var class<FSStructure> PlacingStructureClass; // Structure class selected to be placed
var bool bPlaceStructure; // True when the player has requested to place the structure

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCaptureLocation;
var Rotator MinimapCaptureRotation;
const MinimapCaptureFOV=90;

simulated state Commanding
{
	simulated event BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;

		if (Role == ROLE_Authority)
		{
			// Set commander view location and rotation
			ViewLocation.X = Pawn.Location.X - 2048;
			ViewLocation.Y = Pawn.Location.Y;
			ViewLocation.Z = Pawn.Location.Z + 2048;
			SetLocation(ViewLocation);
			SetRotation(Rotator(Pawn.Location - ViewLocation));
		}

		FSHUD(myHUD).GFxCommanderHUD.Start();
	}

	simulated event EndState(name NextStateName)
	{
		FSHUD(myHUD).GFxCommanderHUD.Close(False);
	}

	simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		// Set view point to controller location and rotation
		out_Location = Location;
		out_Rotation = Rotation;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector MoveAmount;

		Super.PlayerMove(DeltaTime);

		if (PlayerInput.aForward > 0)
			MoveAmount.X = CommanderCameraSpeed;
		else if (PlayerInput.aForward < 0)
			MoveAmount.X = -CommanderCameraSpeed;

		if (PlayerInput.aStrafe > 0)
			MoveAmount.Y = CommanderCameraSpeed;
		else if (PlayerInput.aStrafe < 0)
			MoveAmount.Y = -CommanderCameraSpeed;

		Move(MoveAmount);
	}

	exec function StartFire(optional byte FireModeNum)
	{
		FSHUD(myHUD).BeginDragging();
		PlaceStructure();
	}

	exec function StopFire(optional byte FireModeNum)
	{
		FSHUD(myHUD).EndDragging();
	}

	exec function ToggleCommandView()
	{
		GotoState('PlayerWalking');
	}

	exec function SelectStructure(byte StructureIndex)
	{
		local class<FSStructure> StructureClass;

		StructureClass = class'FSStructure'.static.GetClass(StructureIndex);
		PlacingStructureClass = StructureClass;
		FSHUD(myHUD).StartPreviewStructure(StructureClass);
	}

	exec function PlaceStructure()
	{
		if (PlacingStructureClass != None)
			bPlaceStructure = True;
	}
}

simulated function PostBeginPlay()
{
	local FSMapInfo MI;

	Super.PostBeginPlay();

	MI = FSMapInfo(WorldInfo.GetMapInfo());
	if (MI != None && WorldInfo.NetMode != NM_DedicatedServer)
	{
		MinimapCaptureComponent = new(self) class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'FSAssets.HUD.minimap_render_texture', MinimapCaptureFOV, , 0);
		MinimapCaptureComponent.bUpdateMatrices = False;
		AttachComponent(MinimapCaptureComponent);

		MinimapCaptureLocation.X = MI.MapCenter.X;
		MinimapCaptureLocation.Y = MI.MapCenter.Y;
		MinimapCaptureLocation.Z = MI.MapRadius;
	}
}

function PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);

	MinimapCaptureComponent.SetView(MinimapCaptureLocation, MinimapCaptureRotation);
}

reliable server function ServerSpawnVehicle()
{
	local FSStruct_VehicleFactory VF;

	VF = FSStruct_VehicleFactory(Pawn.Base);

	if (VF != None)
		VF.BuildVehicle(FSPawn(Pawn));
}

reliable server function ServerSpawnStructure(class<FSStructure> StructureClass, Vector StructureLocation)
{
	local FSStructure S;

	S = Spawn(StructureClass,,, StructureLocation, rot(0, 0, 0),,);
	S.TeamNumber = PlayerReplicationInfo.Team.TeamIndex;
}

exec function ReloadWeapon()
{
	FSWeapon(Pawn.Weapon).ServerReload();
}

exec function BuildVehicle()
{
	ServerSpawnVehicle();
}

exec function ToggleCommandView()
{
	if (PlayerReplicationInfo.Team != None)
		GotoState('Commanding');
}

defaultproperties
{
	InputClass=class'FSGame.FSPlayerInput'
	bPlaceStructure=False
	CommanderCameraSpeed=30.0
	SpectatorCameraSpeed=5000.0
	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0)
}