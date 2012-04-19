/*
 * In-game HUD to show health, ammo, player messages, etc.
 */
class EmpGFxHUD extends GFxMoviePlayer;

var GFxObject HealthBar;
var GFxObject AmmoBar;

const BarLength=443.40f;
const BarOffset=33.30f;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	HealthBar = GetVariableObject("_root.HealthBar");
	AmmoBar = GetVariableObject("_root.AmmoBar");
}

function SetHealth(float Health, float MaxHealth)
{
	local ASDisplayInfo DI;

	DI.hasX = true;
	DI.X = -BarLength - BarOffset + (Health / MaxHealth * BarLength);

	HealthBar.SetDisplayInfo(DI);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpGUI.emp_hud'
	bAutoPlay=true
}
