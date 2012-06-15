/**
 * Transfers resources from a resource point to the team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_Refinery extends FStructure;

var() float TransferRate;
var() int TransferAmount;

auto state StructureActive
{
	/**
	 * @extends
	 */
	event BeginState(name PreviousStateName)
	{
		// Begin transferring resources
		SetTimer(TransferRate, True, NameOf(TransferResources));
	}

	/**
	 * @extends
	 */
	event EndState(name NextStateName)
	{
		// Stop transferring resources
		ClearTimer(NameOf(TransferResources));
	}

	/**
	 * Transfers resources from the resource point to the team.
	 */
	function TransferResources()
	{
		FTeamInfo(WorldInfo.Game.GameReplicationInfo.Teams[Team]).Resources += TransferAmount;
	}
}

defaultproperties
{
	TransferRate=1.0
	TransferAmount=1
}
