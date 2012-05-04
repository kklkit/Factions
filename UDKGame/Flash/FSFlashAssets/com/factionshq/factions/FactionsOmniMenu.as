package com.factionshq.factions {

import com.factionshq.data.*;
import flash.display.*;
import flash.external.*;
import scaleform.clik.controls.*;
import scaleform.clik.data.*;
import scaleform.clik.events.*;
import scaleform.gfx.*;

public class FactionsOmniMenu extends MovieClip {
	
	// Frame
	public var menuButtonBar:ButtonBar;
	public var closeButton:Button;
	
	public var panels:Array = ["Team", "Infantry", "Vehicle", "Tactical", "Research"];
	public var menuDataProvider:DataProvider = new DataProvider(panels);
	
	// Team
	public var joinRedTeamButton:Button;
	public var joinSpectatorButton:Button;
	public var joinBlueTeamButton:Button;
	public var redTeamList:ScrollingList;
	public var spectatorList:ScrollingList;
	public var blueTeamList:ScrollingList;
	
	public var redTeamDataProvider:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "red");
	public var spectatorDataProvider:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "spectator");
	public var blueTeamDataProvider:ExternalDataProvider = new ExternalDataProvider("PlayerNames", "blue");
	
	public var selectedTeam:String;
	
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
	
	public var infantryClassDataProvider:ExternalDataProvider = new ExternalDataProvider("ClassNames");
	public var infantryEquipmentDataProviders = [new ExternalDataProvider("EquipmentNames", 0), new ExternalDataProvider("EquipmentNames", 1), new ExternalDataProvider("EquipmentNames", 2), new ExternalDataProvider("EquipmentNames", 3)];
	
	// Vehicle
	public var vehicleChassisList:ScrollingList;
	public var vehicleArmorList:ScrollingList;
	
	public var vehicleChassisDataProvider:ExternalDataProvider = new ExternalDataProvider("ChassisNames");
	public var vehicleArmorDataProvider:ExternalDataProvider = new ExternalDataProvider("ArmorNames");
	
	public function FactionsOmniMenu() {
		super();
		
		Extensions.enabled = true;
		
		menuButtonBar.dataProvider = menuDataProvider;
		menuButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, selectPanel);
		closeButton.addEventListener(ButtonEvent.CLICK, closeMenu);
		
		addFrameScript(0, frameScript0);
		addFrameScript(1, frameScript1);
		addFrameScript(2, frameScript2);
		addFrameScript(3, frameScript3);
		addFrameScript(4, frameScript4);
		
		stop();
	}
	
	public function frameScript0():void {
		menuButtonBar.selectedIndex = 0;
		
		redTeamList.dataProvider = redTeamDataProvider;
		spectatorList.dataProvider = spectatorDataProvider;
		blueTeamList.dataProvider = blueTeamDataProvider;
		
		joinRedTeamButton.label = "Red Team";
		joinRedTeamButton.addEventListener(ButtonEvent.CLICK, createTeamEventListener("red"));
		
		joinSpectatorButton.label = "Spectator";
		joinSpectatorButton.addEventListener(ButtonEvent.CLICK, createTeamEventListener("spectator"));
		
		joinBlueTeamButton.label = "Blue Team";
		joinBlueTeamButton.addEventListener(ButtonEvent.CLICK, createTeamEventListener("blue"));
		
		refreshTeamButtons();
	}
	
	public function frameScript1():void {	
		menuButtonBar.selectedIndex = 1;
		
		infantryArmorLabel.text = "Armor:";
		infantryLightArmorButton.label = "Light Armor";
		infantryHeavyArmorButton.label = "Heavy Armor";
		infantrySkillLabel0.text = "asd";
		
		for (var i:int = 0; i < infantryEquipmentLists.length; ++i) {
			infantryEquipmentLists[i].dataProvider = infantryEquipmentDataProviders[i];
			infantryEquipmentLists[i].addEventListener(ListEvent.ITEM_CLICK, createEquipmentEventListener(i));
		}
	}
	
	public function frameScript2():void {
		menuButtonBar.selectedIndex = 2;
		
		vehicleChassisList.dataProvider = vehicleChassisDataProvider;
		vehicleArmorList.dataProvider = vehicleArmorDataProvider;
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
	
	public function refreshTeamButtons() {
		joinRedTeamButton.selected = selectedTeam == "red";
		joinBlueTeamButton.selected = selectedTeam == "blue";
		joinSpectatorButton.selected = selectedTeam == "spectator";
	}
	
	public function invalidate(item:String) {
		redTeamDataProvider.invalidate();
		spectatorDataProvider.invalidate();
		blueTeamDataProvider.invalidate();
	}
	
	public function updateTeamSelection(teamName:String) {
		selectedTeam = teamName;
		refreshTeamButtons();
	}
	
	public function updateEquipmentList(listNumber:int, listLabel:String) {
		if (listLabel) {
			infantryEquipmentLists[listNumber].visible = true;
			infantryEquipmentLabels[listNumber].visible = true;
			infantryEquipmentLabels[listNumber].text = listLabel;
		} else {
			infantryEquipmentLists[listNumber].visible = false;
			infantryEquipmentLabels[listNumber].visible = false;
		}
	}
	
	public function createTeamEventListener(teamName:String):Function {
		return function(e:ButtonEvent):void {
			ExternalInterface.call("SelectTeam", teamName);
		}
	}
	
	public function createEquipmentEventListener(i:int) {
		return function(e:ListEvent):void {
			ExternalInterface.call("SelectEquipment", i, e.itemData);
		};
	}
	
	public function closeMenu(e:ButtonEvent):void {
		ExternalInterface.call("CloseMenu", this.currentLabel);
	}
	
	public function selectClass(e:ButtonBarEvent):void {
		ExternalInterface.call("SelectClass", e.index);
	}
}
}