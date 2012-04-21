class EmpVehiclePad extends Actor
	Implements(EmpActorInterface)
	Placeable
	AutoExpandCategories(Empires);

var(Empires) int VehicleHealth;
var(Empires) class<UDKVehicle> VehicleClass;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetCollision(true, true);
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	local UDKVehicle SpawnedVehicle;

	Super.Bump(Other, OtherComp, HitNormal);

	if (EmpPawn(Other) != none)
	{
		SpawnedVehicle = Spawn(VehicleClass, , , Location + vect(500, 500, 200));
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

	RemoteRole=ROLE_SimulatedProxy
}