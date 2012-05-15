class FSStructurePreview extends KActorSpawnable
    placeable;

static function Bool CanBuildHere()
{
	return true;
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'FSAssets.Structures.Barracks'
	End Object
	Components.Add(StaticMeshComponent0)

	// Need this to avoid console spam
	Physics = PHYS_None

	// Probably need to fiddle with these for CanBuildHere()
	CollisionType=COLLIDE_BlockAll
	BlockRigidBody=true
	bCollideActors=false
	bBlockActors=true
}