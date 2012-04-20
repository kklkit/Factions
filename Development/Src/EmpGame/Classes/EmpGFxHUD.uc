class EmpGFxHUD extends GFxMoviePlayer;

var GFxObject HealthBar;

const HealthBarWidth=325;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	HealthBar = GetVariableObject("_root.bottomLeftHUD.healthBar");
}

function SetHealth(float Health, float MaxHealth)
{
	local ASDisplayInfo DI;

	DI.hasX = true;
	DI.X = -HealthBarWidth + (Health / MaxHealth * HealthBarWidth);

	HealthBar.SetDisplayInfo(DI);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpFlashAssets.emp_hud'
	bDisplayWithHudOff=false
	bAutoPlay=true
}
