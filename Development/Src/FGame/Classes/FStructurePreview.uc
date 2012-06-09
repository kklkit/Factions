/**
 * Actor used to display the structure preview.
 * 
 * Structure preview is created on the server and is replicated to clients.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructurePreview extends Actor
	dependson(FMapInfo);

var DynamicLightEnvironmentComponent LightEnvironment;
var repnotify FStructureInfo StructureInfo;

replication
{
	if (bNetDirty)
		StructureInfo;
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	// Initialize the structure once the structure info has been set
	if (VarName == 'StructureInfo')
		Initialize();
}

/**
 * Sets the structure preview properties.
 * 
 * Requires the structure info to already be set.
 */
simulated function Initialize()
{
	local UDKSkeletalMeshComponent Mesh;

	if (StructureInfo.Name != '')
	{
		// Create the structure mesh on clients
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