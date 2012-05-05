package com.factionshq.factions {

import com.factionshq.data.*;
import flash.display.*;
import flash.events.Event;
import flash.external.*;
import scaleform.clik.controls.*;
import scaleform.clik.data.*;
import scaleform.clik.events.*;
import scaleform.gfx.*;

public class FactionsOmniMenu extends MovieClip {
	
	private var panels:Array = ["Team", "Infantry", "Vehicle", "Tactical", "Research"];
	private var menuDataProvider:DataProvider = new DataProvider(panels);
	
	private var data:OmniMenuDataManager = new OmniMenuDataManager();
	
	// Frame
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
	public var infantryArmorLabel:Label;
	public var infantryLightArmorButton:Button;
	public var infantryHeavyArmorButton:Button;
	public var infantryEquipmentLabel0:Label;
	public var infantryEquipmentLabel1:Label;
	public var infantryEquipmentLabel2:Label;
	public var infantryEquipmentLabel3:Label;
	public var infantryEquipmentList0:ScrollingList;
	public var infantryEquipmentList1:ScrollingList;
	public var infantryEquipmentList2:ScrollingList;
	public var infantryEquipmentList3:ScrollingList;
	public var infantrySkillLabel0:Label;
	public var infantrySkillLabel1:Label;
	public var infantrySkillLabel2:Label;
	public var infantrySkillLabel3:Label;
	public var infantrySkillList0:ScrollingList;
	public var infantrySkillList1:ScrollingList;
	public var infantrySkillList2:ScrollingList;
	public var infantrySkillList3:ScrollingList;
	
	// Vehicle
	public var vehicleChassisList:ScrollingList;
	public var vehicleArmorList:ScrollingList;
	
	public function FactionsOmniMenu() {
		super();
		
		Extensions.enabled = true;
		
		menuButtonBar.dataProvider = menuDataProvider;
		menuButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, selectPanel);
		
		closeButton.addEventListener(ButtonEvent.CLICK, closeMenu);
		
		data.infantryEquipmentLabels.addEventListener(Event.CHANGE, refreshEquipmentLabels);
		
		addFrameScript(0, frameScript0);
		addFrameScript(1, frameScript1);
		addFrameScript(2, frameScript2);
		addFrameScript(3, frameScript3);
		addFrameScript(4, frameScript4);
		
		stop();
	}
	
	public function frameScript0():void {
		menuButtonBar.selectedIndex = 0;
		
		redTeamList.dataProvider = data.teamRed;
		blueTeamList.dataProvider = data.teamBlue
		spectatorList.dataProvider = data.teamSpectator;
		
		joinRedTeamButton.label = "Red Team";
		joinRedTeamButton.addEventListener(ButtonEvent.CLICK, createTeamSelector("red"));
		
		joinBlueTeamButton.label = "Blue Team";
		joinBlueTeamButton.addEventListener(ButtonEvent.CLICK, createTeamSelector("blue"));
		
		joinSpectatorButton.label = "Spectator";
		joinSpectatorButton.addEventListener(ButtonEvent.CLICK, createTeamSelector("spectator"));
		
		refreshTeamButtons();
	}
	
	public function frameScript1():void {
		menuButtonBar.selectedIndex = 1;
		
		infantryArmorLabel.text = "Armor:";
		infantryLightArmorButton.label = "Light Armor";
		infantryHeavyArmorButton.label = "Heavy Armor";
		
		for (var i:int = 0; i < infantryEquipmentLists.length; ++i) {
			infantryEquipmentLists[i].dataProvider = data.infantryEquipmentNames[i];
			infantryEquipmentLists[i].addEventListener(ListEvent.ITEM_CLICK, createInfantryEquipmentSelector(i));
		}
	}
	
	public function frameScript2():void {
		menuButtonBar.selectedIndex = 2;
		
		vehicleChassisList.dataProvider = data.vehicleChassis;
		vehicleArmorList.dataProvider = data.vehicleArmor;
	}
	
	public function frameScript3():void {
		menuButtonBar.selectedIndex = 3;
	}
	
	public function frameScript4():void {
		menuButtonBar.selectedIndex = 4;
	}
	
	public function get infantryEquipmentLabels():Array {
		return [infantryEquipmentLabel0, infantryEquipmentLabel1, infantryEquipmentLabel2, infantryEquipmentLabel3];
	}
	
	public function get infantryEquipmentLists():Array {
		return [infantryEquipmentList0, infantryEquipmentList1, infantryEquipmentList2, infantryEquipmentList3];
	}
	
	public function get infantrySkillLabels():Array {
		return [infantrySkillLabel0, infantrySkillLabel1, infantrySkillLabel2, infantrySkillLabel3];
	}
	
	public function get infantrySkillLists():Array {
		return [infantrySkillList0, infantrySkillList1, infantrySkillList2, infantrySkillList3];
	}
	
	public function selectPanel(e:ButtonBarEvent):void {
		gotoAndStop(panels[e.index]);
	}
	
	public function refreshTeamButtons():void {
		var teamName = data.team.requestItemAt(0);
		joinRedTeamButton.selected = teamName == "red";
		joinBlueTeamButton.selected = teamName == "blue";
		joinSpectatorButton.selected = teamName == "spectator";
	}
	
	public function refreshEquipmentLabels(event:Event):void {
		for (var i:int = 0; i < infantryEquipmentLabels.length; ++i) {
			data.infantryEquipmentLabels.requestItemAt(i, function(item:Object):void {
					infantryEquipmentLabels[i].text = String(item);
				});
		}
	}
	
	// Functions called from UnrealScript
	
	public function invalidate(item:String):void {
		if (item == "team") {
			data.teamRed.invalidate();
			data.teamBlue.invalidate();
			data.teamSpectator.invalidate();
		} else if (item == "equipment labels") {
			data.infantryEquipmentLabels.invalidate();
		}
	}
	
	// Functions calling UnrealScript
	
	public function createTeamSelector(teamName:String):Function {
		return function(e:ButtonEvent):void {
			ExternalInterface.call("SelectTeam", teamName);
		}
	}
	
	public function createInfantryEquipmentSelector(i:int):Function {
		return function(e:ListEvent):void {
			ExternalInterface.call("SelectInfantryEquipment", i, e.itemData);
		};
	}
	
	public function closeMenu(e:ButtonEvent):void {
		ExternalInterface.call("CloseMenu", this.currentLabel);
	}
	
	public function selectArmor(e:ButtonBarEvent):void {
		ExternalInterface.call("SelectInfantryArmor", e.index);
	}
}
}