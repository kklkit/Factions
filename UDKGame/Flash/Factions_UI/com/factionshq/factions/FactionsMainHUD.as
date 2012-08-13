package com.factionshq.factions {

import fl.motion.*;
import flash.display.*;
import flash.events.*;
import flash.external.*;
import flash.geom.*;
import flash.text.*;
import scaleform.gfx.*;
	
public class FactionsMainHUD extends MovieClip {
	public var topLeftHUD:MovieClip;
	public var topRightHUD:MovieClip;
	
	public var commHealthBarStartPositionX:Number = topLeftHUD.getChildByName('commHealthBar').x;
	
	public function FactionsMainHUD() {
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
		topRightHUD.x = x1;
	}
	
	public function updateResources(resources:int):void {
		var resourceCount:TextField = topRightHUD.getChildByName('resourceCount') as TextField;
		resourceCount.text = resources.toString();
	}
	
	public function updateCommStatus(name:String, health:int, healthMax:int):void {
		var commName:TextField = topLeftHUD.getChildByName('commName') as TextField;
		var commHealthBar:DisplayObject = topLeftHUD.getChildByName('commHealthBar');
		var colorInfo:ColorTransform = commHealthBar.transform.colorTransform;
		
		if (name == "") {
			commName.text = "No commander!";
			commName.textColor = 0xff0000;
		} else {
			commName.text = name;
			commName.textColor = 0x000000;
		}
		
		// Check for divide by zero
		if (healthMax === 0) {
			health = 0;
			healthMax = 1;
		}
		
		var percent:Number = health / healthMax;
		
		if (percent > 0.5) {        
            colorInfo.color = Color.interpolateColor(0xffff00, 0x00ff00, (percent - 0.5) / 0.5);
        } else {
            colorInfo.color = Color.interpolateColor(0xff0000, 0xffff00, percent / 0.5);
        }

		commHealthBar.transform.colorTransform = colorInfo;
		
		commHealthBar.x = -commHealthBar.width + commHealthBarStartPositionX + (percent * commHealthBar.width);
	}
	
	public function updateCurrentResearch(research:String, secsLeft:int):void {
		var currentResearch:TextField = topLeftHUD.getChildByName('currentResearch') as TextField;
		
		if (research == "") {
			currentResearch.text = "No research!";
			currentResearch.textColor = 0xff0000;
		} else {
			var mins:String = Math.floor(secsLeft / 60).toString();
			var secs:String = zeroPad(secsLeft % 60, 2);
			
			currentResearch.text = research + " (" + mins + ":" + secs + ")";
			currentResearch.textColor = 0x000000;
		}
	}
	
	public function updateRoundTimer(secsElapsed:int):void {
		var roundTimer:TextField = topRightHUD.getChildByName("roundTimer") as TextField;
		
		var hrs:String = Math.floor(secsElapsed / 3600).toString();
		var mins:String = zeroPad(Math.floor(secsElapsed % 3600) / 60, 2);
		var secs:String = zeroPad(secsElapsed % 60, 2);
		
		roundTimer.text = ((hrs == "0") ? "" : hrs + ":") + mins + ":" + secs;
	}
	
	public function zeroPad(number:int, width:int):String {
		var ret:String = "" + number;
		while (ret.length < width)
			ret = "0" + ret;
		return ret;
	}
}
}
