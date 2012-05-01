package com.factionshq.factions
{
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.external.ExternalInterface;
	import scaleform.gfx.Extensions;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.text.TextField;

	public class FactionsHUD extends MovieClip
	{
		public var topLeftHUD:MovieClip;
		public var topRightHUD:MovieClip;
		public var bottomLeftHUD:MovieClip;
		public var bottomRightHUD:MovieClip;
		public var healthBarStartPositionX:Number = bottomLeftHUD.getChildByName('healthBar').x;
		public var ammoBarStartPositionX:Number = bottomRightHUD.getChildByName('ammoBar').x;

		public function FactionsHUD()
		{
			Extensions.enabled = true;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, function () {
				ExternalInterface.call("ResizeHUD");
			});
		}

		public function UpdateHealth(health:int, healthMax:int):void
		{
			var healthBar:DisplayObject = bottomLeftHUD.getChildByName('healthBar');

			// Divide by zero protection
			if (healthMax === 0)
			{
				health = 0;
				healthMax = 1;
			}

			healthBar.x = -healthBar.width + healthBarStartPositionX + (health / healthMax * healthBar.width);
		}
		
		public function UpdateAmmo(ammo:int, ammoMax:int):void
		{
			var ammoBar:DisplayObject = bottomRightHUD.getChildByName('ammoBar');
			
			// Divide by zero protection
			if (ammoMax === 0)
			{
				ammo = 0;
				ammoMax = 1;
			}
			
			ammoBar.x = ammoBar.width + ammoBarStartPositionX - (ammo / ammoMax * ammoBar.width);
		}

		public function UpdateResources(resources:int):void
		{
			var resourceCount:TextField = topRightHUD.getChildByName('resourceCount') as TextField;
			resourceCount.text = resources.toString();
		}
		
		public function UpdateCommStatus(name:String, health:int, healthMax:int):void
		{
			var commName:TextField = topLeftHUD.getChildByName('commName') as TextField;
			
			if (name == "")
			{
				commName.text = "No commander!";
				commName.textColor = 0xFF0000;
			}
			else
			{
				commName.text = name;
				commName.textColor = 0x000000;
				//todo: colour name according to health
			}
		}
		
		public function UpdateCurrentResearch(research:String, secsLeft:int):void
		{
			var currentResearch:TextField = topLeftHUD.getChildByName('currentResearch') as TextField;
			
			if (research == "")
			{
				currentResearch.text = "No research!";
				currentResearch.textColor = 0xFF0000;
			}
			else
			{
				var mins:int = Math.floor(secsLeft / 60);
				var secs:int = secsLeft % 60;
			
				currentResearch.text = research + " (" + mins + ":" + zeroPad(secs, 2) + ")";
				currentResearch.textColor = 0x000000;
			}
		}
		
		public function zeroPad(number:int, width:int):String
		{
			var ret:String = "" + number;
			while (ret.length < width)
				ret = "0" + ret;
			return ret;
		}
	}
}