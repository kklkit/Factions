class EmpVehiclePad extends Actor
	Placeable
	AutoExpandCategories(Empires);

var(Empires) int VehicleHealth;
var(Empires) class<UDKVehicle> VehicleClass;

event PostBeginPlay()
{
	SetCollision(true, true);
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	local UDKVehicle SpawnedVehicle;

	Super.Bump(Other, OtherComp, HitNormal);
	if (bool(Other.GetALocalPlayerController()))
	{
		SpawnedVehicle = Spawn(VehicleClass,,,Location + vect(500, 500, 200));
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

	VehicleHealth=100
	VehicleClass=class'UTVehicle_Scorpion_Content'
}