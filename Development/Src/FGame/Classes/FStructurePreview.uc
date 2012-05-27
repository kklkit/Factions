class FStructurePreview extends Actor
	dependson(FMapInfo);

var DynamicLightEnvironmentComponent LightEnvironment;

simulated function Initialize(FStructureInfo StructureInfo)
{
	local UDKSkeletalMeshComponent Mesh;

	Mesh = new(Self) class'UDKSkeletalMeshComponent';
	Mesh.SetSkeletalMesh(StructureInfo.Archetype.Mesh.SkeletalMesh);
	Mesh.SetLightEnvironment(LightEnvironment);
	AttachComponent(Mesh);
	SetDrawScale(StructureInfo.Archetype.DrawScale);
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	RemoteRole=ROLE_SimulatedProxy
}