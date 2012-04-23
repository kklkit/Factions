package name.jephir.factions
{
	import flash.display.MovieClip;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonBarEvent;
	import scaleform.clik.controls.ButtonBar;

	public class FactionsOmniMenu extends MovieClip
	{
		public var menus:Array;
		public var menuButtonBar:ButtonBar;
		public var teamButtonBar:ButtonBar;
		public var infantryArmorButtonBar;
		public var infantrySlot1;
		public var infantrySlot2;
		public var infantrySlot3;
		public var infantrySlot4;
		public var chassisList;
		public var vehicleArmorList;
		
		private var playerTeam:int = 0;
		
		public function SetPlayerTeam(teamIndex:int):void
		{
			playerTeam = teamIndex;
		}
		
		private function onItemClick(e:ButtonBarEvent):void
		{
			gotoAndPlay(menus[e.index]);
		}

		public function FactionsOmniMenu()
		{
			super();
			
			menus = ["Team", "Infantry", "Vehicle", "Tactical", "Research"]

			menuButtonBar.dataProvider = new DataProvider(menus);
			menuButtonBar.selectedIndex = 0;
			menuButtonBar.addEventListener(ButtonBarEvent.BUTTON_SELECT, onItemClick);
		}
	}
}