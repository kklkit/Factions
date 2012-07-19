package com.factionshq.factions {

import flash.display.*;
import flash.events.*;
import flash.ui.Keyboard;
import flash.external.*;
import flash.geom.ColorTransform;
import flash.text.*;
import flash.utils.Timer;
import fl.motion.Color;
import scaleform.gfx.*;
import scaleform.clik.controls.TextInput;
import scaleform.clik.controls.TextArea;
import scaleform.clik.controls.ScrollBar;

public class FactionsHUD extends MovieClip {
	public var topLeftHUD:MovieClip;
	public var topRightHUD:MovieClip;
	public var bottomLeftHUD:MovieClip;
	public var bottomRightHUD:MovieClip;
	public var commHealthBarStartPositionX:Number = topLeftHUD.getChildByName('commHealthBar').x;
	public var healthBarStartPositionX:Number = bottomLeftHUD.getChildByName('healthBar').x;
	public var ammoBarStartPositionX:Number = bottomRightHUD.getChildByName('ammoBar').x;
		
	public var chatLogBoxChatHistoryHTML:String = "";
	public var definedColor:Array = new Array("#FF2500", "#2500FF", "#CCCCCC", "#E08ECD","#25FFFF");
		//definedColor[0] is red (red team)
		//definedColor[1] is blue (Blue team)
		//definedColor[2] is grey (Spectator)
		//definedColor[3] is light red (Red team commander)
		//definedColor[4] is light blue (Blue team commander)
		
	public var htmlLineBreak:String = "<br />";
	
	public function FactionsHUD() {
		super();
		
		Extensions.enabled = true;
		
		// Temproarily disable the scroll bar until chat history is implemented
		var myScrollbar:ScrollBar = bottomLeftHUD.getChildByName("chatLogBoxScrollBar") as ScrollBar
		myScrollbar.visible = false;			
		
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
	
	public function updateVehicleHealth(health:int, healthMax:int):void {
		var vehicleBody:DisplayObject = bottomLeftHUD.getChildByName('vehicleBody');
		var colorInfo:ColorTransform = vehicleBody.transform.colorTransform;
		var percent:Number = health / healthMax;
		
		if (percent > 0.5) {                      
            colorInfo.color = Color.interpolateColor(0xffff00, 0x00ff00, (percent - 0.5) / 0.5);
        } else {
            colorInfo.color = Color.interpolateColor(0xff0000, 0xffff00, percent / 0.5);
        }
		
		vehicleBody.transform.colorTransform = colorInfo;
	}
	
	public function updateVehicleRotation(rotation:int):void {
		var vehicleBody:DisplayObject = bottomLeftHUD.getChildByName('vehicleBody');
		vehicleBody.rotation = rotation;
	}
	
	public function showVehicleHUD(showHUD:Boolean):void {
		var vehicleBody:DisplayObject = bottomLeftHUD.getChildByName('vehicleBody');
		var vehicleTurret:DisplayObject = bottomLeftHUD.getChildByName('vehicleTurret');
		
		vehicleBody.visible = showHUD;
		vehicleTurret.visible = showHUD;
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
	
	public function enableChatInputBox():void {
		var myChatInputBox:TextInput = bottomLeftHUD.getChildByName("chatInputBox") as TextInput;
		myChatInputBox.focused = 1;
		myChatInputBox.visible = true;
	}
	
	public function disableChatInputBox():void {
		var myChatLogBox:TextArea = bottomLeftHUD.getChildByName("chatLogBox") as TextArea;
		var myChatInputBox:TextInput = bottomLeftHUD.getChildByName("chatInputBox") as TextInput;
		myChatLogBox.focused = 1;
		myChatInputBox.visible = false;
	}
	
	public function getChatInputBoxText():String {
		var myChatInputBox:TextInput = bottomLeftHUD.getChildByName("chatInputBox") as TextInput;		
		return myChatInputBox.text;		
	}
	
	public function setChatInputBoxText(setText:String):void{
		var myChatInputBox:TextInput = bottomLeftHUD.getChildByName("chatInputBox") as TextInput;		
		myChatInputBox.text = setText;			
	}
	
	function convertTextToHTML(srcText:String):String{
		var index:int;
		
		index = srcText.indexOf("<");		
		
		var firstHalf:String;
		var secondHalf:String;
		
		while (index != -1)
		{
			firstHalf = "";
			secondHalf = "";
			if (index > 0)
				firstHalf = srcText.substring(0,index-1);
			if (srcText.length > index + 1)
				secondHalf = srcText.substring(index+1,srcText.length);
			
			srcText = firstHalf + "&lt;" + secondHalf;					
			index = srcText.indexOf("<");						
		}
		
		index = srcText.indexOf(">");
		while (index != -1)
		{
			firstHalf = "";
			secondHalf = "";
			
			if (index > 0)
				firstHalf = srcText.substring(0,index);
			if (srcText.length > index + 1)
				secondHalf = srcText.substring(index+1,srcText.length);
			
			srcText = firstHalf + "&gt;" + secondHalf;					
			index = srcText.indexOf(">");						
		}
		return srcText;
	}
	
	public function addNewChatLine(chatLine:String, preferedColor:int):void {
		var myChatLogBox:TextArea = bottomLeftHUD.getChildByName("chatLogBox") as TextArea;
		
		var tempString:String = "";
		
		chatLine = convertTextToHTML(chatLine);
		if (preferedColor >= 0 && preferedColor <= 4)
			tempString = "<font color='" + definedColor[preferedColor] + "'>" + chatLine + "</font>"
							+ htmlLineBreak;
		myChatLogBox.htmlText += tempString;
		chatLogBoxChatHistoryHTML += tempString;
		
		var chatLogDecayTimer:Timer = new Timer(6000, 1);
		chatLogDecayTimer.start();
		chatLogDecayTimer.addEventListener(TimerEvent.TIMER, onChatLogDecay);
	
		
	}
	
	function onChatLogDecay(e:TimerEvent):void {
		var tempString:String = "";
		var myChatLogBox:TextArea = bottomLeftHUD.getChildByName("chatLogBox") as TextArea;
		var firstLineBreakBeginPosition:int;
		
		firstLineBreakBeginPosition = myChatLogBox.htmlText.indexOf(htmlLineBreak);
		
		if (firstLineBreakBeginPosition)
		{
			if(myChatLogBox.htmlText.length > (firstLineBreakBeginPosition + htmlLineBreak.length))
			{
				tempString = myChatLogBox.htmlText.substring(firstLineBreakBeginPosition + htmlLineBreak.length, myChatLogBox.htmlText.length);
				myChatLogBox.htmlText = tempString;
			}
			else
				myChatLogBox.htmlText = "";	
			
		}
					
		
		
		
		
		
	}
	
	
}
}