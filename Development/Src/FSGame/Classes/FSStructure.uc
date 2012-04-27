/**
 * Base structure class.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStructure extends Actor
	implements(FSActorInterface)
	placeable
	abstract;

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bSynthesizeSHLight=true
		bUseBooleanEnvironmentShadowing=false
		ModShadowFadeoutTime=0.75f
		bIsCharacterLightEnvironment=true
		bAllowDynamicShadowsOnTranslucency=true
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		LightEnvironment=LightEnvironment0
	End Object
	Components.Add(StaticMeshComponent0)

	CollisionType=COLLIDE_BlockAll
	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=true
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.f
	bAlwaysRelevant=true
	bReplicateMovement=false
	bOnlyDirtyReplication=true
}
