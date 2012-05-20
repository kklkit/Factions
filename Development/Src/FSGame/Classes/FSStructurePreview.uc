class FSStructurePreview extends KActorSpawnable
    placeable;

static function bool CanBuildHere()
{
	return True;
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ST_BarracksMash.Mesh.S_ST_BarracksMash'
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