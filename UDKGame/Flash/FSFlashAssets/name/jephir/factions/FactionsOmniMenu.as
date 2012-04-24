package name.jephir.factions
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

		private var panels:Array = ["Team","Infantry","Vehicle","Tactical","Research"];
		private var menuDataProvider:DataProvider = new DataProvider(panels);
		private var teamDataProvider:DataProvider = new DataProvider(["Red","Blue","Spectator"]);
		private var infantryClassDataProvider:DataProvider = new DataProvider(["Soldier","Support"]);
		private var infantryTinyEquipmentDataProvider:DataProvider = new DataProvider(["Combat Knife","Grenade","Sticky Bomb","AP Mine","AT Mine"]);
		private var infantrySmallEquipmentDataProvider:DataProvider = new DataProvider(["Heavy Pistol","Auto Pistol","Omni Tool"]);
		private var infantryMediumEquipmentDataProvider:DataProvider = new DataProvider(["SMG","Shotgun"]);
		private var infantryLargeEquipmentDataProvider:DataProvider = new DataProvider(["Heavy Rifle","HMG","Grenade Launcher"]);
		private var vehicleChassisDataProvider:DataProvider = new DataProvider(["Jeep","APC","Light Tank","Medium Tank","Heavy Tank","Artillery Tank","Gunship","Bomber","Dropship","Blimp"]);
		private var vehicleArmorDataProvider:DataProvider = new DataProvider(["Reflective","Absorbent","Composite","Reactive","Regenerative"]);

		private var teamIndex:int = 2;
		private var infantryClassIndex:int = 0;
		private var infantryEquipmentIndicies:Array = [0,0,0,0];
		private var vehicleChassisIndex:int = 0;
		private var vehicleArmorIndex:int = 0;

		public function FactionsOmniMenu()
		{
			super();

			Extensions.enabled = true;

			menuButtonBar.dataProvider = menuDataProvider;
			menuButtonBar.selectedIndex = 0;
			menuButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, onButtonBarSelect);

			closeButton.addEventListener(ButtonEvent.CLICK, onCloseButtonClick);
		}

		private function onButtonBarSelect(e:ButtonBarEvent):void
		{
			gotoAndPlay(panels[e.index]);
		}
		
		private function onCloseButtonClick(e:ButtonEvent):void
		{
			ExternalInterface.call("CloseOmniMenu", this.currentLabel);
		}

		private function onTeamButtonBarSelect(e:ButtonBarEvent):void
		{
			ExternalInterface.call("SelectTeam", e.index);
			gotoAndPlay("Infantry");
		}
		
		private function selectClass(e:IndexEvent):void
		{
			ExternalInterface.call("SelectClass", e.data);
		}
		
		private function selectEquipment(e:ListEvent):void
		{
			ExternalInterface.call("SelectEquipment", e.itemData);
		}

		public function UpdateTeam(teamIndex:int):void
		{
			this.teamIndex = teamIndex;
		}
	}
}