class EmpPlayerController extends UDKPlayerController;

var bool IsInCommanderView;
var bool IsInCommanderRotate;
var bool bViewingMap;

var vector PlayerViewOffset;

var Pawn CommanderPawn;

state CommanderView extends BaseSpectating
{
		function UpdateRotation( float DeltaTime )
		{
			if( IsInCommanderRotate )
				super.UpdateRotation( DeltaTime );
		}		
}

exec function ToggleCommanderRotate()
{
	if( IsInCommanderRotate )
		IsInCommanderRotate = false;
	else
		IsInCommanderRotate = true;
}

exec function ToggleCommanderHeight()
{

}

exec function ToggleCommanderView()
{
	if( IsInCommanderView )
	{
		IsInCommanderView = false;
		
		if( Vehicle(Pawn) != None )
			Possess(CommanderPawn,true);
		else
			Possess(CommanderPawn,false);
			
		GotoState('PlayerWalking');
	}
	else
	{
		IsInCommanderView = true;

		GotoState('CommanderView');
		CommanderPawn = Pawn;
		UnPossess();
		
		bCollideWorld = true;
		SetLocation(Pawn.Location+PlayerViewOffset);
	}
}

exec function ToggleViewMap()
{
	bViewingMap = !bViewingMap;
}

exec function ToggleMenu()
{
	local EmpHUD myEmpHUD;
	local EmpGFxHUDMenu myEmpGFxHUDMenu;

	myEmpHUD = EmpHUD(myHUD);
	if (myEmpHUD != none)
	{
		myEmpGFxHUDMenu = myEmpHUD.GFxHUDMenu;
		if (myEmpGFxHUDMenu.bMovieIsOpen)
		{
			myEmpGFxHUDMenu.Close(false);
		}
		else
		{
			myEmpGFxHUDMenu.Start(false);
		}
	}
}

simulated event GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
{
	if (bViewingMap)
	{
		out_Location = vect(0, 0, 20000);
		out_Rotation = rot(-16384, -16384, 0);
	} else {
		super.GetPlayerViewPoint(out_Location, out_Rotation);
	}
}

defaultproperties
{
	IsInCommanderView=false
	IsInCommanderRotate=false
	bViewingMap=false
	PlayerViewOffset=(X=-64,Y=0,Z=1024)
}