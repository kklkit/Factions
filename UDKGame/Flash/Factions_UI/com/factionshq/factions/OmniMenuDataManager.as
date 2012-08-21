package com.factionshq.factions {
	import com.factionshq.data.ExternalDataProvider;
	import scaleform.clik.data.DataProvider;
	
	public class OmniMenuDataManager {
		public var teamSelectionName:ExternalDataProvider = new ExternalDataProvider("PlayerTeam");
		public var teamRedPlayerNames:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "red");
		public var teamBluePlayerNames:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "blue");
		public var teamSpectatorPlayerNames:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "spectator");
		public var infantryPresetNames:ExternalDataProvider = new ExternalDataProvider("InfantryPresetNames");
		public var infantryClassSelectionName:ExternalDataProvider = new ExternalDataProvider("InfantryClass");
		public var infantryClassNames:ExternalDataProvider = new ExternalDataProvider("InfantryClassNames");
		public var infantryEquipmentSelectionNames:ExternalDataProvider = new ExternalDataProvider("InfantryEquipment");
		public var infantryEquipmentLabels:ExternalDataProvider = new ExternalDataProvider("InfantryEquipmentLabels");
		public var infantryEquipmentNames:Array = [new ExternalDataProvider("InfantryEquipmentNames", 0), new ExternalDataProvider("InfantryEquipmentNames", 1), new ExternalDataProvider("InfantryEquipmentNames", 2), new ExternalDataProvider("InfantryEquipmentNames", 3)];
		public var vehicleChassisNames:ExternalDataProvider = new ExternalDataProvider("VehicleChassisNames");
		public var vehicleArmorNames:ExternalDataProvider = new ExternalDataProvider("VehicleArmorNames");
		public var vehicleWeaponNames:Array = [new ExternalDataProvider("VehicleWeaponNames", 0), new ExternalDataProvider("VehicleWeaponNames", 1), new ExternalDataProvider("VehicleWeaponNames", 2), new ExternalDataProvider("VehicleWeaponNames", 3)];
	}
}