class EmpPlayerController extends UDKPlayerController;

var bool IsInCommanderView;
var bool IsInCommanderRotate;

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

defaultproperties
{
	IsInCommanderView = false;
	IsInCommanderRotate = false;
	PlayerViewOffset=(X=-64,Y=0,Z=1024)
}