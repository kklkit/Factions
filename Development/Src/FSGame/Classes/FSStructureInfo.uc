class FSStructureInfo extends Object
	config(StructureInfo);

struct StructureInfo
{
	var name Name;
	var class<FSStructure> Class;
	var SkeletalMesh Mesh;
	var float Scale;
};

var config array<StructureInfo> Structures;

defaultproperties
{
}