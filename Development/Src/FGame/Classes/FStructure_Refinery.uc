/**
 * Transfers resources from a resource point to the team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_Refinery extends FStructure;

var() float TransferRate; // Resources transferred per second
var() int TransferAmount;
var() int Resources; // Total resources this refinery has

state Active
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		// Begin transferring resources
		if (Role == ROLE_Authority)
			SetTimer(TransferRate, True, NameOf(TransferResources));
	}

	/**
	 * @extends
	 */
	event EndState(name NextStateName)
	{
		// Stop transferring resources
		ClearTimer(NameOf(TransferResources));

		Super.EndState(NextStateName);
	}

	/**
	 * Transfers resources from the resource point to the team.
	 */
	function TransferResources()
	{
		local int ResourcesToTransfer;

		// Transfer the full amount of resources if there are enough resources in the refinery
		if (Resources >= TransferAmount)
		{
			ResourcesToTransfer = TransferAmount;
		}
		// Otherwise stop transferring resources and transfer what's left
		else
		{
			ClearTimer(NameOf(TransferResources));
			ResourcesToTransfer = Resources;
		}

		Resources -= ResourcesToTransfer;
		FTeamInfo(WorldInfo.Game.GameReplicationInfo.Teams[Team]).Resources += ResourcesToTransfer;
	}
}

defaultproperties
{
	TransferRate=1.0
	TransferAmount=1
	Resources=5000
}
