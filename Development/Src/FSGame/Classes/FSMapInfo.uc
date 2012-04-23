class FSMapInfo extends MapInfo;

var() int RecommendedPlayersMin, RecommendedPlayersMax;

var(Minimap) Vector2d MapCenter;

var(Minimap) float MapRadius;

defaultproperties
{
	MapCenter=(X=0,Y=0)
	MapRadius=20000
}
