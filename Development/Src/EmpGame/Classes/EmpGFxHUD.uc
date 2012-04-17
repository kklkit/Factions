class EmpGFxHUD extends GFxMoviePlayer;

var GFxObject HealthBar;
var GFxObject AmmoBar;

function bool Start(optional bool StartPaused = false)
{
	Super.Start(StartPaused);
	Advance(0);

	HealthBar = GetVariableObject("_root.HealthBar");
	AmmoBar = GetVariableObject("_root.AmmoBar");

	return true;
}

function SetHealth(float Health, float MaxHealth)
{
	local ASDisplayInfo DI;

	DI.hasXScale = true;
	DI.XScale = Health / MaxHealth * 100;

	HealthBar.SetDisplayInfo(DI);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpGUI.emp_hud'
}
