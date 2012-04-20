class EmpGFxHUDBottomLeft extends EmpGFxHUD;

var GFxObject HealthBar;

const HealthBarWidth=325;
const HealthBarStageOffset=-25.1f;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	HealthBar = GetVariableObject("_root.HealthBar");
}

function SetHealth(float Health, float MaxHealth)
{
	local ASDisplayInfo DI;

	DI.hasX = true;
	DI.X = -HealthBarWidth + HealthBarStageOffset + (Health / MaxHealth * HealthBarWidth);

	HealthBar.SetDisplayInfo(DI);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpFlashAssets.emp_hud_bottom_left'
}
