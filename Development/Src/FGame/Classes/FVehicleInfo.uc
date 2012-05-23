class FVehicleInfo extends Object
	config(VehicleInfo);

struct VehicleInfo
{
	var name Name;
	var class<FVehicle> Class;
};

var config array<VehicleInfo> Vehicles;

defaultproperties
{
}
