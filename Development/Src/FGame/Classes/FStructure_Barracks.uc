class FStructure_Barracks extends FStructure;

// List of socket names where players can spawn
var() array<name> PlayerStartSockets;

var array<FTeamPlayerStart> PlayerStarts;

state Active
{
	/**
	 * @extends
	 */
	simulated event BeginState(name PreviousStateName)
	{
		local name PlayerStartSocketName;
		local Vector PlayerStartLocation;

		Super.BeginState(PreviousStateName);

		if (Role == ROLE_Authority)
		{
			// Create a start location at each socket
			foreach PlayerStartSockets(PlayerStartSocketName)
			{
				Mesh.GetSocketWorldLocationAndRotation(PlayerStartSocketName, PlayerStartLocation);
				PlayerStarts.AddItem(Spawn(class'FTeamPlayerStart', Self,, PlayerStartLocation, Rotation,,));
				if (PlayerStarts[PlayerStarts.Length - 1] != None)
				{
					PlayerStarts[PlayerStarts.Length - 1].TeamNumber = Team;
					PlayerStarts[PlayerStarts.Length - 1].TeamIndex = Team;
				}
			}
		}
	}

	/**
	 * @extends
	 */
	event EndState(name NextStateName)
	{
		local FTeamPlayerStart PlayerStart;

		Super.EndState(NextStateName);

		foreach PlayerStarts(PlayerStart)
		{
			PlayerStart.Destroy();
		}

		FTeamGame(WorldInfo.Game).PlayerStatusChanged();
	}
}

defaultproperties
{
}
