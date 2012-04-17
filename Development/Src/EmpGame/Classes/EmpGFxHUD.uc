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

	DI.hasX = true;
	DI.X = -443.30f - 33.30f + (Health / MaxHealth * 443.30f);

	HealthBar.SetDisplayInfo(DI);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpGUI.emp_hud'
}
