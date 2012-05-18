class FSVehicleInfo extends Object
	config(VehicleInfo);

struct VehicleInfo
{
	var name Name;
	var class<FSVehicle> Class;
};

var config array<VehicleInfo> Vehicles;

defaultproperties
{
}
