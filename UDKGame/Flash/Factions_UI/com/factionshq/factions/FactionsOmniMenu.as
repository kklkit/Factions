package com.factionshq.factions {

import com.factionshq.data.*;
import flash.display.*;
import flash.external.*;
import scaleform.clik.controls.*;
import scaleform.clik.data.*;
import scaleform.clik.events.*;
import scaleform.gfx.*;

public class FactionsOmniMenu extends MovieClip {
	
	private var data:OmniMenuDataManager = new OmniMenuDataManager();
	
	// Frame
	private var panels:Array = ["Team", "Squad", "Infantry", "Vehicle", "Research"];
	private var menuDataProvider:DataProvider = new DataProvider(panels);
	public var menuHeader:MovieClip;
	public var menuButtonBar:ButtonBar;
	public var closeButton:Button;
	
	// Team
	public var joinRedTeamButton:Button;
	public var joinSpectatorButton:Button;
	public var joinBlueTeamButton:Button;
	public var redTeamList:ScrollingList;
	public var spectatorList:ScrollingList;
	public var blueTeamList:ScrollingList;
	
	// Infantry
	public var infantryPresetNameBox:TextInput;
	public var infantryPresetsList:ScrollingList;
	public var infantryClassLabel:Label;
	public var infantryClassButtonBar:ButtonBar;
	public var infantryEquipmentLabel0:Label;
	public var infantryEquipmentLabel1:Label;
	public var infantryEquipmentLabel2:Label;
	public var infantryEquipmentLabel3:Label;
	public var infantryEquipmentList0:ScrollingList;
	public var infantryEquipmentList1:ScrollingList;
	public var infantryEquipmentList2:ScrollingList;
	public var infantryEquipmentList3:ScrollingList;
	
	// Vehicle
	public var vehicleChassisLabel:Label;
	public var vehicleChassisList:ScrollingList;
	public var vehicleArmorLabel:Label;
	public var vehicleArmorList:ScrollingList;
	public var vehicleWeaponLabel0:Label;
	public var vehicleWeaponList0:ScrollingList;
	public var vehicleWeaponLabel1:Label;
	public var vehicleWeaponList1:ScrollingList;
	public var vehicleBuildButton:Button;
	
	// Global
	public function FactionsOmniMenu() {
		super();
		
		Extensions.enabled = true;
		
		closeButton.addEventListener(ButtonEvent.CLICK, closeMenu);
		
		menuButtonBar.dataProvider = menuDataProvider;
		menuButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, gotoPanel);
		
		addFrameScript(0, teamScript);
		addFrameScript(1, squadScript);
		addFrameScript(2, infantryScript);
		addFrameScript(3, vehicleScript);
		addFrameScript(4, researchScript);
		
		stop();
		
		menuHeader.gotoAndStop("yellow");
	}
	
	// Team
	private function teamScript():void {
		menuButtonBar.selectedIndex = 0;
		
		redTeamList.dataProvider = data.teamRedPlayerNames;
		blueTeamList.dataProvider = data.teamBluePlayerNames;
		spectatorList.dataProvider = data.teamSpectatorPlayerNames;
		
		joinRedTeamButton.label = "Red Team";
		joinRedTeamButton.addEventListener(ButtonEvent.CLICK, function(e:ButtonEvent):void {
			ExternalInterface.call("SelectTeam", "red");
		});
		
		joinBlueTeamButton.label = "Blue Team";
		joinBlueTeamButton.addEventListener(ButtonEvent.CLICK, function(e:ButtonEvent):void {
			ExternalInterface.call("SelectTeam", "blue");
		});
		
		joinSpectatorButton.label = "Spectator";
		joinSpectatorButton.addEventListener(ButtonEvent.CLICK, function(e:ButtonEvent):void {
			ExternalInterface.call("SelectTeam", "spectator");
		});
		
		updateTeamSelection();
	}
	
	private function updateTeamSelection():void {
		var teamName = data.teamSelectionName.requestItemAt(0);
		
		if (teamName == "Red") {
			menuHeader.gotoAndStop("red");
		} else if (teamName == "Blue") {
			menuHeader.gotoAndStop("blue");
		} else {
			menuHeader.gotoAndStop("yellow");
		}
		
		joinRedTeamButton.selected = teamName == "Red";
		joinBlueTeamButton.selected = teamName == "Blue";
		joinSpectatorButton.selected = teamName == "Spectator";
	}
	
	// Squad
	private function squadScript():void {
		menuButtonBar.selectedIndex = 1;
	}
	
	// Infantry
	private function infantryScript():void {
		menuButtonBar.selectedIndex = 2;
		
		infantryClassLabel.text = "Class:";
		
		// Presets
		infantryPresetsList.dataProvider = data.infantryPresetNames;
		
		// Equipment list
		for (var i:int = 0; i < infantryEquipmentLists.length; ++i) {
			infantryEquipmentLists[i].dataProvider = data.infantryEquipmentNames[i];
		}
		
		// Class bar
		infantryClassButtonBar.dataProvider = data.infantryClassNames;
		infantryClassButtonBar.itemRendererName = "AnimatedToggleButton";
		infantryClassButtonBar.buttonWidth = infantryClassButtonBar.width / infantryClassButtonBar.dataProvider.length - 1;
		infantryClassButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, selectInfantryClass);
		
		updateClassSelection();
		updateEquipmentLabels();
		updateEquipmentSelection();
	}
	
	private function updateClassSelection():void {
		infantryClassButtonBar.selectedIndex = data.infantryClassNames.indexOf(data.infantryClassSelectionName.requestItemAt(0));
	}
	
	private function updateEquipmentLabels():void {
		for (var i:int = 0; i < infantryEquipmentLabels.length; ++i) {
			data.infantryEquipmentLabels.requestItemAt(i, function(item:Object):void {
				if (item == null)
				{
					infantryEquipmentLabels[i].visible = false;
					infantryEquipmentLists[i].visible = false;
					infantryEquipmentLists[i].selectedIndex = -1;
				}
				else
				{
					infantryEquipmentLabels[i].visible = true;
					infantryEquipmentLists[i].visible = true;
					infantryEquipmentLabels[i].text = item as String;
				}
			});
		}
	}
	
	private function updateEquipmentSelection():void {
		for (var i:int = 0; i < infantryEquipmentLists.length; ++i) {
			infantryEquipmentLists[i].selectedIndex = data.infantryEquipmentNames[i].indexOf(data.infantryEquipmentSelectionNames.requestItemAt(i) as String);
		}
	}
	
	private function get infantryEquipmentLabels():Array {
		return [infantryEquipmentLabel0, infantryEquipmentLabel1, infantryEquipmentLabel2, infantryEquipmentLabel3];
	}
	
	private function get infantryEquipmentLists():Array {
		return [infantryEquipmentList0, infantryEquipmentList1, infantryEquipmentList2, infantryEquipmentList3];
	}
	
	private function selectInfantryClass(e:ButtonBarEvent):void {
		data.infantryClassNames.requestItemAt(e.index, function(item:Object) {
			ExternalInterface.call("SelectInfantryClass", item);
		});
	}
	
	private function selectLoadout():void {
		var equipmentNames:Array = [];
		var equipmentIndex:int;
		
		for (var i = 0; i < infantryEquipmentLists.length; i++)
		{
			equipmentIndex = infantryEquipmentLists[i].selectedIndex;
			
			if (equipmentIndex >= 0)
			{
				equipmentNames.push(data.infantryEquipmentNames[i].requestItemAt(equipmentIndex));
			}
		}
		
		ExternalInterface.call("SelectInfantryLoadout", equipmentNames);
	}
	
	// Vehicle
	private function vehicleScript():void {
		menuButtonBar.selectedIndex = 3;
		
		vehicleChassisLabel.text = "Chassis:";
		vehicleArmorLabel.text = "Armor:";
		vehicleWeaponLabel0.text = "Weapon 1:";
		vehicleWeaponLabel1.text = "Weapon 2:";
		
		vehicleChassisList.dataProvider = data.vehicleChassisNames;
		vehicleArmorList.dataProvider = data.vehicleArmorNames;
		vehicleWeaponList0.dataProvider = data.vehicleWeaponNames[0];
		vehicleWeaponList1.dataProvider = data.vehicleWeaponNames[1];
		
		vehicleBuildButton.label = "Build";
		vehicleBuildButton.addEventListener(ButtonEvent.CLICK, buildVehicle);
		
		vehicleChassisList.addEventListener(ListEvent.ITEM_CLICK, function (e:ListEvent):void {
			data.vehicleChassisNames.requestItemAt(e.index, function (chassisName:Object):void {
				ExternalInterface.call("SelectVehicleChassis", chassisName as String);
			});
		});
	}
	
	private function buildVehicle(e:ButtonEvent) {
		data.vehicleChassisNames.requestItemAt(vehicleChassisList.selectedIndex, function (chassisName:Object):void {
			data.vehicleWeaponNames[0].requestItemAt(vehicleWeaponList0.selectedIndex, function (weaponName1:Object):void {
				data.vehicleWeaponNames[1].requestItemAt(vehicleWeaponList1.selectedIndex, function (weaponName2:Object):void {
					ExternalInterface.call("BuildVehicle", chassisName as String, [weaponName1 as String, weaponName2 as String]);
					closeMenu();
				});
			});
		});
	}
	
	// Research
	private function researchScript():void {
		menuButtonBar.selectedIndex = 4;
	}
	
	// Other
	private function gotoPanel(e:ButtonBarEvent):void {
		gotoAndStop(panels[e.index]);
	}
	
	private function closeMenu(e:ButtonEvent = null):void {
		ExternalInterface.call("CloseMenu", this.currentLabel);
	}
	
	// Functions called from UnrealScript
	public function invalidate(item:String):void {
		if (item == "team") {
			data.teamRedPlayerNames.invalidate();
			data.teamBluePlayerNames.invalidate();
			data.teamSpectatorPlayerNames.invalidate();
			updateTeamSelection();
		} else if (item == "infantry equipment labels") {
			data.infantryEquipmentLabels.invalidate();
			updateEquipmentLabels();
		} else if (item == "infantry equipment selection") {
			data.infantryEquipmentNames.invalidate();
			updateEquipmentSelection();
		} else if (item == "vehicle equipment") {
			data.vehicleWeaponNames[0].invalidate();
			data.vehicleWeaponNames[1].invalidate();
			data.vehicleWeaponNames[2].invalidate();
			data.vehicleWeaponNames[3].invalidate();
		}
	}
	
	public function onClose():void {
		if (this.currentLabel == "Infantry")
		{
			selectLoadout();
		}
	}
}
}