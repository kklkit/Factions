class FStructurePreview extends Actor
	dependson(FMapInfo);

var DynamicLightEnvironmentComponent LightEnvironment;
var repnotify FStructureInfo StructureInfo;

replication
{
	if (bNetDirty)
		StructureInfo;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'StructureInfo')
		Initialize();
}

simulated function Initialize()
{
	local UDKSkeletalMeshComponent Mesh;

	if (StructureInfo.Name != '')
	{
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			Mesh = new(Self) class'UDKSkeletalMeshComponent';
			Mesh.SetSkeletalMesh(StructureInfo.Archetype.Mesh.SkeletalMesh);
			Mesh.SetLightEnvironment(LightEnvironment);
			AttachComponent(Mesh);
		}

		if (Role == ROLE_Authority)
		{
			SetDrawScale(StructureInfo.Archetype.DrawScale);
		}
	}
	else
	{
		`log("Structure info not found when initializing" @ Name);
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	RemoteRole=ROLE_SimulatedProxy
	bUpdateSimulatedPosition=True
}