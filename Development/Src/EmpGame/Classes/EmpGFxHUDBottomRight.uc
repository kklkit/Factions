class EmpGFxHUDBottomRight extends EmpGFxHUD;

var GFxObject AmmoBar;

const BarLength=443.40f;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	AmmoBar = GetVariableObject("_root.AmmoBar");
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpFlashAssets.emp_hud_bottom_right'
	bAutoPlay=true
}
