/**
 * Used by mappers to set custom map parameters.
 * 
 * The MyMapInfo property in World Properties needs to be set to FSMapInfo to access these variables.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSMapInfo extends UDKMapInfo;

var() int RecommendedPlayersMin, RecommendedPlayersMax;

var(Minimap) Vector2D MapCenter;
var(Minimap) float MapRadius;

defaultproperties
{
	MapCenter=(X=0,Y=0)
	MapRadius=20000
}
