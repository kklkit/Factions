class FWeaponInfo extends Object
	config(WeaponInfo);

struct WeaponInfo
{
	var name Name;
	var string Mesh;
	var float DrawScale;
};

var config array<WeaponInfo> Weapons;

defaultproperties
{
}
