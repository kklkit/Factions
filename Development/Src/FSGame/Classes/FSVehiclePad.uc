class FSVehiclePad extends Actor
	Implements(FSActorInterface)
	Placeable
	AutoExpandCategories(Factions);

var(Factions) int VehicleHealth;
var(Factions) class<UDKVehicle> VehicleClass;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetCollision(true, true);
}

function Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	local UDKVehicle SpawnedVehicle;

	Super.Bump(Other, OtherComp, HitNormal);

	if (FSPawn(Other) != none)
	{
		SpawnedVehicle = Spawn(VehicleClass, , , Location + vect(500, 500, 200));
		SpawnedVehicle.HealthMax = VehicleHealth;
		SpawnedVehicle.Health = VehicleHealth;
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StructureStaticMesh
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object
	Components.Add(StructureStaticMesh)
	
	bCanStepUpOn=true
	bCollideComplex=true

	VehicleHealth=100
	VehicleClass=class'UTVehicle_Scorpion_Content'

	RemoteRole=ROLE_SimulatedProxy
}