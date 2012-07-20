package com.factionshq.factions {
	
import flash.display.*;
import flash.events.*;
import flash.ui.Keyboard;
import flash.external.*;
import flash.text.*;
import flash.utils.Timer;
import scaleform.gfx.*;
import scaleform.clik.controls.TextArea;
import scaleform.clik.controls.ScrollBar;
import scaleform.clik.controls.TextInput;



public class FactionsChat extends MovieClip {
	public var ChatContainer:MovieClip;	
	public var htmlLineBreak:String = "<br />";
	public var chatLogBoxChatHistoryHTML:String = "";	
	public var definedColor:Array = new Array("#FF2500", "#2500FF", "#CCCCCC", "#E08ECD","#25FFFF");
	public var msgAliveDuration:int = 10000;   // How long the chat message stays before disappearing
	
		//definedColor[0] is red (Red team)
		//definedColor[1] is blue (Blue team)
		//definedColor[2] is grey (Spectator)
		//definedColor[3] is light red (Red team commander)
		//definedColor[4] is light blue (Blue team commander)
		
	
	
	public function FactionsChat() {
		super();		
		Extensions.enabled = true;
					
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
				
		// Temproarily disable the scroll bar until chat history is implemented
		var myScrollbar:ScrollBar = ChatContainer.getChildByName("chatLogBoxScrollBar") as ScrollBar;
		myScrollbar.visible = false;
		
		var myChatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;
		myChatInputBox.visible = false;
	}
	
	public function enableChatInputBox():void {
		var myChatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;
		myChatInputBox.visible = true;
		myChatInputBox.focused = 1;
	}
	
	public function disableChatInputBox():void {
		var myChatLogBox:TextArea = ChatContainer.getChildByName("chatLogBox") as TextArea;
		myChatLogBox.focused = 1;
		
		var myChatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;
		myChatInputBox.visible = false;
	}
	
	public function getChatInputBoxText():String {
		var myChatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;		
		return myChatInputBox.text;		
	}
	
	public function setChatInputBoxText(setText:String):void{
		var myChatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;		
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
		var myChatLogBox:TextArea = ChatContainer.getChildByName("chatLogBox") as TextArea;		
		var tempString:String = "";
		
		chatLine = convertTextToHTML(chatLine);
		if (preferedColor >= 0 && preferedColor <= 4)
			tempString = "<font color='" + definedColor[preferedColor] + "'>" + chatLine + "</font>"
							+ htmlLineBreak;
		myChatLogBox.htmlText += tempString;
		chatLogBoxChatHistoryHTML += tempString;
		
		var chatLogDecayTimer:Timer = new Timer(msgAliveDuration, 1);
		chatLogDecayTimer.start();
		chatLogDecayTimer.addEventListener(TimerEvent.TIMER, onChatLogDecay);
	
		
	}
	
	function onChatLogDecay(e:TimerEvent):void {
		var tempString:String = "";
		var myChatLogBox:TextArea = ChatContainer.getChildByName("chatLogBox") as TextArea;
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