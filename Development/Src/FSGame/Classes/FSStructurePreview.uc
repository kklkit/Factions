class FSStructurePreview extends Actor
	dependson(FSStructureInfo);

var DynamicLightEnvironmentComponent LightEnvironment;

simulated function Initialize(StructureInfo StructureInfo)
{
	local UDKSkeletalMeshComponent Mesh;

	Mesh = new(Self) class'UDKSkeletalMeshComponent';
	Mesh.SetSkeletalMesh(StructureInfo.Mesh);
	Mesh.SetLightEnvironment(LightEnvironment);
	AttachComponent(Mesh);
	SetDrawScale(StructureInfo.Scale);
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	RemoteRole=ROLE_None

	// Need this to avoid console spam
	Physics=PHYS_None
}