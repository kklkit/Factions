/**
 * Base structure class.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStructure extends Actor
	abstract;

defaultproperties
{
	bStatic=true
	bHidden=false
	bOnlyOwnerSee=false
	bWorldGeometry=true
	bNetTemporary=false
	bOnlyRelevantToOwner=false
	bMovable=false
	bCollideWhenPlacing=true
	bCollideActors=true
	bCollideWorld=false
	bBlockActors=true

	RemoteRole=ROLE_SimulatedProxy
}
