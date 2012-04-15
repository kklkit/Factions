class EmpVehiclePad extends Actor
	Placeable;

event PostBeginPlay()
{
	SetCollision(true, true);
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	Super.Bump(Other, OtherComp, HitNormal);
	if (bool(Other.GetALocalPlayerController()))
	{
		Spawn(class'UTVehicle_Scorpion_Content',,,Location + vect(500, 500, 200));
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StructureStaticMesh
		StaticMesh=StaticMesh'EmpAssets.Structures.VehiclePad'
	End Object
	Components.Add(StructureStaticMesh)
	
	bCanStepUpOn=true
	bCollideComplex=true
}