/**
 * Structure defining information about an infantry class.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSClassInfo extends Object
	dependson(FSPawn)
	config(GameFS)
	abstract;

enum EEquipmentType
{
	EC_Tiny,
	EC_Small,
	EC_Medium,
	EC_Large
};

var config string ClassName;

var config array<EEquipmentType> EquipmentHolsters;

defaultproperties
{
}
