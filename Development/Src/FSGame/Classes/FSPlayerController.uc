/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerController extends UDKPlayerController;

// Commander
var() byte CommandViewMoveSpeed;

// Structure placement: SelectStructure -> FSHUD.SpawnStructure -> ServerSpawnStructure
// The spawn structure call is in the HUD because Canvas.DeProject is used to get the structure coordinates
var bool bPlaceStructure; // True when the player has requested to place the structure
var class<FSStructure> PlacingStructureClass; // Structure class selected to be placed

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCapturePosition;
var Rotator MinimapCaptureRotation;
const MinimapCaptureFOV=90;

simulated state Commanding
{
	simulated function BeginState(name PreviousStateName)
	{
		local Vector ViewLocation;

		// Set commander view location and rotation
		ViewLocation.X = Pawn.Location.X - 2048;
		ViewLocation.Y = Pawn.Location.Y;
		ViewLocation.Z = Pawn.Location.Z + 2048;
		SetLocation(ViewLocation);
		SetRotation(Rotator(Pawn.Location - ViewLocation));

		FSHUD(myHUD).GFxCommanderHUD.Start();

		Super.BeginState(PreviousStateName);
	}

	simulated function EndState(name NextStateName)
	{
		FSHUD(myHUD).GFxCommanderHUD.Close(False);

		Super.EndState(NextStateName);
	}

	simulated function GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
	{
		// Set view point to controller location and rotation
		out_Location = Location;
		out_Rotation = Rotation;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector NextLocation;

		NextLocation = Location;

		if (PlayerInput.aForward > 0)
			NextLocation.X += CommandViewMoveSpeed;
		else if (PlayerInput.aForward < 0)
			NextLocation.X -= CommandViewMoveSpeed;

		if (PlayerInput.aStrafe > 0)
			NextLocation.Y += CommandViewMoveSpeed;
		else if (PlayerInput.aStrafe < 0)
			NextLocation.Y -= CommandViewMoveSpeed;

		SetLocation(NextLocation);
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

		MinimapCapturePosition.X = MI.MapCenter.X;
		MinimapCapturePosition.Y = MI.MapCenter.Y;
		MinimapCapturePosition.Z = MI.MapRadius;
	}
}

function PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);

	MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
}

reliable server function RequestVehicle()
{
	local FSStruct_VehicleFactory VF;

	VF = FSStruct_VehicleFactory(Pawn.Base);

	if (VF != None)
		VF.BuildVehicle(FSPawn(Pawn));
}

reliable server function ServerSpawnStructure(Vector StructureLocation, class<FSStructure> StructureClass)
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
	RequestVehicle();
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
	CommandViewMoveSpeed=30
	SpectatorCameraSpeed=5000.0

	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0)
}