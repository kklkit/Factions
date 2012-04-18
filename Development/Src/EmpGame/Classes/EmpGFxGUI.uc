class EmpGFxGUI extends GFxMoviePlayer;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	SetViewScaleMode(SM_NoScale);
	SetAlignment(Align_Center);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpGUI.emp_gui'
	bAutoPlay=false
}