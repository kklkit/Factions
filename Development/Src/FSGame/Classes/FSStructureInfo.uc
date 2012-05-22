class FSStructureInfo extends Object
	config(StructureInfo);

struct StructureInfo
{
	var name Name;
	var class<FSStructure> Class;
};

var config array<StructureInfo> Structures;

defaultproperties
{
}