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
	
	public var selectedTeam:String = "spectator";
	
	// Infantry
	public var infantryClassButtonBar:ButtonBar;
	public var infantryEquipmentList0:ScrollingList;
	public var infantryEquipmentList1:ScrollingList;
	public var infantryEquipmentList2:ScrollingList;
	public var infantryEquipmentList3:ScrollingList;
	
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
		
		updateTeamButtons();
	}
	
	public function frameScript1():void {
		var infantryEquipmentLists:Array = [infantryEquipmentList0, infantryEquipmentList1, infantryEquipmentList2, infantryEquipmentList3];
		var eventListeners:Array;
		
		menuButtonBar.selectedIndex = 1;
		
		for (var i:int = 0; i < infantryEquipmentLists.length; ++i) {
			infantryEquipmentLists[i].dataProvider = infantryEquipmentDataProviders[i];
			infantryEquipmentLists[i].addEventListener(ListEvent.ITEM_CLICK, createEquipmentEventListener(i));
		}
		
		infantryClassButtonBar.dataProvider = infantryClassDataProvider;
		infantryClassButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, selectClass);
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
	
	public function selectPanel(e:ButtonBarEvent):void {
		gotoAndStop(panels[e.index]);
	}
	
	public function updateTeamButtons() {
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
		updateTeamButtons();
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