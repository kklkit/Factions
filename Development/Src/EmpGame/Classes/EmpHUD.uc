class EmpHUD extends UDKHUD;

function DrawHud()
{
	Canvas.SetPos(Canvas.ClipX/2,Canvas.ClipY/2);
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.Font = class'Engine'.static.GetMediumFont();
	Canvas.DrawText("Hello World");
}

defaultproperties
{
}