/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStructure extends Vehicle
	abstract;

var() byte Team;

/**
 * Returns the class for the given structure index.
 */
static function class<FSStructure> GetClass(byte StructureIndex)
{
	switch (StructureIndex)
	{
	case 1:
		return class'FSStruct_Barracks';
	case 2:
		return class'FSStruct_VehicleFactory';
	default:
		return None;
	}
}

//TODO: Change these classes with something semitransparent or w/e
static function class<FSStructurePreview> GetPreviewClass(class<FSStructure> StructureClass)
{
	switch (StructureClass)
	{
	case class'FSStruct_Barracks':
		return class'FSStructurePreview'; 
	case class'FSStruct_VehicleFactory':
		return class'FSStructurePreview';
	default:
		return None;
	}
}

simulated event byte ScriptGetTeamNum()
{
	return Team;
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=UDKSkeletalMeshComponent Name=StructureMesh
		LightEnvironment=LightEnvironment0
		CollideActors=True
		BlockActors=True
		BlockRigidBody=True
		BlockZeroExtent=True
		BlockNonZeroExtent=True
		bUseSingleBodyPhysics=1
	End Object
	CollisionComponent=StructureMesh
	Mesh=StructureMesh
	Components.Add(StructureMesh)

	bMovable=False
	CollisionType=COLLIDE_BlockAll
	bCollideActors=True
	bBlockActors=True

	Team=0
	Health=1000
	HealthMax=1000
}
