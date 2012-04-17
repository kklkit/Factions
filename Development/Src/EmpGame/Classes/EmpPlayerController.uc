class EmpPlayerController extends UDKPlayerController;

var bool IsInCommanderView;

var vector PlayerViewOffset;

var Pawn CommanderPawn;

state CommanderView extends BaseSpectating
{
		// WiP, code in here would check if "ALT" is toggled, if so release or lock Rotator
		function UpdateRotation( float DeltaTime )
		{

		}		
}

exec function ToggleCommanderView()
{
	if( IsInCommanderView )
	{
		IsInCommanderView = false;
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

simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
{
	super.GetPlayerViewPoint(out_Location, out_Rotation );
}

defaultproperties
{
	IsInCommanderView = false;
	PlayerViewOffset=(X=-64,Y=0,Z=1024)
}