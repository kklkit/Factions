class FSWeaponInfo extends Object
	config(WeaponInfo);

struct WeaponInfo
{
	var name Name;
	var string Mesh;
};

var config array<WeaponInfo> Weapons;

defaultproperties
{
}
