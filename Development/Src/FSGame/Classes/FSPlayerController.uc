class FSPlayerController extends PlayerController;

var bool InCommanderView;

var bool bViewingMap;

state CommanderView extends PlayerWalking
{

}

exec function ToggleCommanderView2()
{
	InCommanderView = !InCommanderView;
	
	if( InCommanderView )
		GotoState('CommanderView');
	else
		GotoState('PlayerWalking');
}

exec function ToggleViewMap()
{
	bViewingMap = !bViewingMap;
}

simulated function GetPlayerViewPoint(out Vector out_Location, out Rotator out_Rotation)
{
	if (Role < ROLE_Authority && bViewingMap)
	{
		out_Location = vect(0, 0, 20000);
		out_Rotation = rot(-16384, -16384, 0);
	} else {
		super.GetPlayerViewPoint(out_Location, out_Rotation);
	}
}

defaultproperties
{
	InputClass=class'FSGame.FSPlayerInput'
	InCommanderView=false
	bViewingMap=false
}