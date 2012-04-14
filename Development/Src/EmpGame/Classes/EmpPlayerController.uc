class EmpPlayerController extends UDKPlayerController;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	`log("Hello world and welcome to Empires UDK");
}

defaultproperties
{
}