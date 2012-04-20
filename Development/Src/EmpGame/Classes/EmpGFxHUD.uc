class EmpGFxHUD extends GFxMoviePlayer;

var GFxObject HealthBar;
var GFxObject TopLeftHUD;
var GFxObject TopRightHUD;
var GFxObject BottomLeftHUD;
var GFxObject BottomRightHUD;

const HealthBarWidth=325;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	SetViewScaleMode(SM_NoScale);
	SetAlignment(Align_TopLeft);

	HealthBar = GetVariableObject("_root.bottomLeftHUD.healthBar");
	TopLeftHUD = GetVariableObject("_root.topLeftHUD");
	TopRightHUD = GetVariableObject("_root.topRightHUD");
	BottomLeftHUD = GetVariableObject("_root.bottomLeftHUD");
	BottomRightHUD = GetVariableObject("_root.bottomRightHUD");
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
