package com.factionshq.factions
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import scaleform.gfx.Extensions;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ButtonBar;
	import scaleform.clik.controls.Button;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.events.ButtonBarEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.ListEvent;

	public class FactionsOmniMenu extends MovieClip
	{
		public var menuButtonBar:ButtonBar;
		public var closeButton:Button;

		public var panels:Array = ["Team","Infantry","Vehicle","Tactical","Research"];
		public var menuDataProvider:DataProvider = new DataProvider(panels);
		
		public var teamDataProvider:DataProvider = new DataProvider(["Red","Blue","Spectator"]);
		public var teamIndex:int = 2;

		public var infantryClassDataProvider:DataProvider = new DataProvider(["Soldier","Support"]);
		public var infantryClassIndex:int = 0;
		
		public var infantryEquipmentDataProviders = [
		 new DataProvider(["None", "Battle Rifle", "Assault Rifle"]),
		 new DataProvider(["None"]),
		 new DataProvider(["None", "Heavy Pistol"]),
		 new DataProvider(["None"])
		 ];
		public var infantryEquipmentIndicies:Array = [0,0,0,0];

		public var vehicleChassisDataProvider:DataProvider = new DataProvider(["Jeep","APC","Light Tank","Medium Tank","Heavy Tank","Artillery Tank","Gunship","Bomber","Dropship","Blimp"]);
		public var vehicleChassisIndex:int = 0;
		
		public var vehicleArmorDataProvider:DataProvider = new DataProvider(["Reflective","Absorbent","Composite","Reactive","Regenerative"]);
		public var vehicleArmorIndex:int = 0;

		public function FactionsOmniMenu()
		{
			super();

			Extensions.enabled = true;

			menuButtonBar.dataProvider = menuDataProvider;
			menuButtonBar.selectedIndex = 0;
			menuButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, selectPanel);

			closeButton.addEventListener(ButtonEvent.CLICK, closeMenu);
		}

		private function selectPanel(e:ButtonBarEvent):void
		{
			gotoAndPlay(panels[e.index]);
		}

		private function closeMenu(e:ButtonEvent):void
		{
			ExternalInterface.call("CloseOmniMenu", this.currentLabel);
		}

		private function selectTeam(e:ButtonBarEvent):void
		{
			ExternalInterface.call("SelectTeam", e.index);
			gotoAndPlay("Infantry");
		}

		private function selectClass(e:ButtonBarEvent):void
		{
			ExternalInterface.call("SelectClass", e.index);
		}

		public function UpdateTeam(teamIndex:int):void
		{
			this.teamIndex = teamIndex;
		}

		public function UpdateEquipmentSelection(slot:int, equipmentName:String):void
		{
			infantryEquipmentIndicies[slot] = infantryEquipmentDataProviders[slot].indexOf(equipmentName);
		}
		
		public function UpdateClassSelection(classIndex:int):void
		{
			infantryClassIndex = classIndex;
		}
	}
}