class EmpVehiclePad extends Actor
	Placeable
	AutoExpandCategories(Empires);

var(Empires) int VehicleHealth;

event PostBeginPlay()
{
	SetCollision(true, true);
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	local UTVehicle_Scorpion_Content SpawnedVehicle;

	Super.Bump(Other, OtherComp, HitNormal);
	if (bool(Other.GetALocalPlayerController()))
	{
		SpawnedVehicle = Spawn(class'UTVehicle_Scorpion_Content',,,Location + vect(500, 500, 200));
		SpawnedVehicle.HealthMax = VehicleHealth;
		SpawnedVehicle.Health = VehicleHealth;
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

	VehicleHealth=100;
}