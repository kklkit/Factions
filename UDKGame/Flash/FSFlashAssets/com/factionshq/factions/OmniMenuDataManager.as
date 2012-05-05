package com.factionshq.factions {
import com.factionshq.data.ExternalDataProvider;
import scaleform.clik.data.DataProvider;

public class OmniMenuDataManager {
	public var team:ExternalDataProvider = new ExternalDataProvider("PlayerTeam");
	public var teamRed:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "red");
	public var teamBlue:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "blue");
	public var teamSpectator:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "spectator");
	public var infantryEquipmentLabels:ExternalDataProvider = new ExternalDataProvider("InfantryEquipmentLabels");
	public var infantryEquipmentNames:Array = [new ExternalDataProvider("InfantryEquipmentNames", 0), new ExternalDataProvider("InfantryEquipmentNames", 1), new ExternalDataProvider("InfantryEquipmentNames", 2), new ExternalDataProvider("InfantryEquipmentNames", 3)];
	public var infantrySkillLabels:ExternalDataProvider = new ExternalDataProvider("InfantrySkillLabels");
	public var infantrySkillNames:Array = [new ExternalDataProvider("InfantrySkillNames", 0), new ExternalDataProvider("InfantrySkillNames", 1), new ExternalDataProvider("InfantrySkillNames", 2), new ExternalDataProvider("InfantrySkillNames", 3)];
	public var vehicleChassis:ExternalDataProvider = new ExternalDataProvider("VehicleChassisNames");
	public var vehicleArmor:ExternalDataProvider = new ExternalDataProvider("VehicleArmorNames");
}
}