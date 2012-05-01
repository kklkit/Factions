/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStructure extends Actor
	implements(FSActorInterface)
	placeable
	abstract;

var() byte TeamNumber;

simulated function byte ScriptGetTeamNum()
{
	return TeamNumber;
}

static function class<FSStructure> GetStructureClass(byte StructureIndex)
{
	switch (StructureIndex)
	{
	case 1:
		return class'FSStruct_Barracks';
	case 2:
		return class'FSStruct_VehicleFactory';
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=StructureLightEnvironmentComponent
		bSynthesizeSHLight=true
		bUseBooleanEnvironmentShadowing=false
		ModShadowFadeoutTime=0.75f
		bIsCharacterLightEnvironment=true
		bAllowDynamicShadowsOnTranslucency=true
	End Object
	Components.Add(StructureLightEnvironmentComponent)

	Begin Object Class=StaticMeshComponent Name=StructureMeshComponent
		LightEnvironment=StructureLightEnvironmentComponent
	End Object
	Components.Add(StructureMeshComponent)

	CollisionType=COLLIDE_BlockAll
	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=true
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.0
	bAlwaysRelevant=true
	bReplicateMovement=false
	bOnlyDirtyReplication=true

	TeamNumber=0
}
