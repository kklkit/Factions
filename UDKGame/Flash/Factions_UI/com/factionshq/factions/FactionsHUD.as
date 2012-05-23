package com.factionshq.factions {

import flash.display.*;
import flash.events.*;
import flash.external.*;
import flash.text.*;
import scaleform.gfx.*;

public class FactionsHUD extends MovieClip {
	public var topLeftHUD:MovieClip;
	public var topRightHUD:MovieClip;
	public var bottomLeftHUD:MovieClip;
	public var bottomRightHUD:MovieClip;
	public var healthBarStartPositionX:Number = bottomLeftHUD.getChildByName('healthBar').x;
	public var ammoBarStartPositionX:Number = bottomRightHUD.getChildByName('ammoBar').x;
	
	public function FactionsHUD() {
		super();
		
		Extensions.enabled = true;
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.RESIZE, function() {
				ExternalInterface.call("ResizeHUD");
			});
		
		ExternalInterface.call("ResizeHUD");
	}
	
	public function updateResolution(x0:Number, y0:Number, x1:Number, y1:Number) {
		bottomLeftHUD.y = y1;
		bottomRightHUD.y = y1;
		topRightHUD.x = x1;
		bottomRightHUD.x = x1;
	}
	
	public function updateHealth(health:int, healthMax:int):void {
		var healthBar:DisplayObject = bottomLeftHUD.getChildByName('healthBar');
		
		// Check for divide by zero
		if (healthMax === 0) {
			health = 0;
			healthMax = 1;
		}
		
		healthBar.x = -healthBar.width + healthBarStartPositionX + (health / healthMax * healthBar.width);
	}
	
	public function updateAmmo(ammo:int, ammoMax:int):void {
		var ammoBar:DisplayObject = bottomRightHUD.getChildByName('ammoBar');
		
		// Check for divide by zero
		if (ammoMax === 0) {
			ammo = 0;
			ammoMax = 1;
		}
		
		ammoBar.x = ammoBar.width + ammoBarStartPositionX - (ammo / ammoMax * ammoBar.width);
	}
	
	public function updateMagazineCount(mags:int):void {
		var magCount:TextField = bottomRightHUD.getChildByName('magCount') as TextField;
		magCount.text = mags.toString();
	}
	
	public function updateResources(resources:int):void {
		var resourceCount:TextField = topRightHUD.getChildByName('resourceCount') as TextField;
		resourceCount.text = resources.toString();
	}
	
	public function updateCommStatus(name:String, health:int, healthMax:int):void {
		var commName:TextField = topLeftHUD.getChildByName('commName') as TextField;
		
		if (name == "") {
			commName.text = "No commander!";
			commName.textColor = 0xFF0000;
		} else {
			commName.text = name;
			commName.textColor = 0x000000;
				//todo: colour name according to health
		}
	}
	
	public function updateCurrentResearch(research:String, secsLeft:int):void {
		var currentResearch:TextField = topLeftHUD.getChildByName('currentResearch') as TextField;
		
		if (research == "") {
			currentResearch.text = "No research!";
			currentResearch.textColor = 0xFF0000;
		} else {
			var mins:int = Math.floor(secsLeft / 60);
			var secs:int = secsLeft % 60;
			
			currentResearch.text = research + " (" + mins + ":" + zeroPad(secs, 2) + ")";
			currentResearch.textColor = 0x000000;
		}
	}
	
	public function zeroPad(number:int, width:int):String {
		var ret:String = "" + number;
		while (ret.length < width)
			ret = "0" + ret;
		return ret;
	}
}
}