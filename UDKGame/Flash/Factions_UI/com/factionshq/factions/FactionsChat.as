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
	public var msgAliveDuration:int = 10000;   // How long the chat message stays before disappearing
	
	public var chatLogBoxChatHistoryHTML:String = "";
	public var chatLogBoxChatCurrentHTML:String = "";
	public var bHistoryMode = false;
	public var bTeamChat = false;
	
	public var definedColor:Array = new Array("#FF2500", "#2500FF", "#CCCCCC", "#E08ECD","#25FFFF");
	
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
		
		var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
		historyChatLogContainer.visible = false;
		
		var myChatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;
		myChatInputBox.visible = false;
	
		var myChatState:MovieClip = ChatContainer.getChildByName("chatState") as MovieClip;
		myChatState.visible = false;
		
		myChatInputBox.addEventListener(KeyboardEvent.KEY_DOWN,onInputBoxKeyDown);
	}
	
	public function onInputBoxKeyDown(e:KeyboardEvent):void {
		if (e.keyCode == Keyboard.ENTER)
		{
			ExternalInterface.call("SendChat", getChatInputBoxText(), this.bTeamChat);
			setChatInputBoxText("");
		}
	}
	
	public function enableChatInputBox(chatChannel:String):void {
		if (chatChannel.toLowerCase() == 'team')
			bTeamChat = true;
		else
			bTeamChat = false;
		
		var chatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;
		chatInputBox.visible = true;
		chatInputBox.focused = 1;
		
		var chatState:MovieClip = ChatContainer.getChildByName("chatState") as MovieClip;
		chatState.visible = true;
		if (bTeamChat)
			chatState.gotoAndStop(2);
		else
			chatState.gotoAndStop(1);
			
		var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
		currentChatLogTextArea.visible = false;
		var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
		historyChatLogContainer.visible = true;	
		var historyChatLogTextArea:TextArea = historyChatLogContainer.getChildByName("historyChatLogTextArea") as TextArea;
		historyChatLogTextArea.position = 10000;  //Scroll to bottom
	}
	
	public function disableChatInputBox():void {
		var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
		currentChatLogTextArea.focused = 1;
			
		var chatInputBox:TextInput = ChatContainer.getChildByName("chatInputBox") as TextInput;
		chatInputBox.visible = false;		
		
		var chatState:MovieClip = ChatContainer.getChildByName("chatState") as MovieClip;
		chatState.visible = false;
		
		var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
		historyChatLogContainer.visible = false;
		currentChatLogTextArea.visible = true;
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
		var tempString:String = "";
		
		chatLine = convertTextToHTML(chatLine);
		if (preferedColor >= 0 && preferedColor <= 4)
			tempString = "<font color='" + definedColor[preferedColor] + "'>" + chatLine + "</font>"
							+ htmlLineBreak;
		
		var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
		currentChatLogTextArea.htmlText += tempString;
		currentChatLogTextArea.position = 10000; // Scroll to the bottom
		
		var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
		var historyChatLogTextArea:TextArea = historyChatLogContainer.getChildByName("historyChatLogTextArea") as TextArea;
		historyChatLogTextArea.htmlText += tempString;
		
		historyChatLogTextArea.position =  10000; // Scroll to the bottom
		
		var chatLogDecayTimer:Timer = new Timer(msgAliveDuration, 1);
		chatLogDecayTimer.start();
		chatLogDecayTimer.addEventListener(TimerEvent.TIMER, onChatLogDecay);	
		
	}
	
	function onChatLogDecay(e:TimerEvent):void {
		var tempString:String = "";
		var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
		var firstLineBreakBeginPosition:int;
		
		firstLineBreakBeginPosition = currentChatLogTextArea.htmlText.indexOf(htmlLineBreak);
		
		if (firstLineBreakBeginPosition)
		{
			if(currentChatLogTextArea.htmlText.length > (firstLineBreakBeginPosition + htmlLineBreak.length))
			{
				tempString = currentChatLogTextArea.htmlText.substring(firstLineBreakBeginPosition + htmlLineBreak.length, currentChatLogTextArea.htmlText.length);
				currentChatLogTextArea.htmlText = tempString;
			}
			else
			{
				currentChatLogTextArea.htmlText = "";
			}
		}		
	}
}
}