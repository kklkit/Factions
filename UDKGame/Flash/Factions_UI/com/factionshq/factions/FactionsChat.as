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
	import com.factionshq.factions.FactionsTextInput;
	import flash.system.*;
	
	public class FactionsChat extends MovieClip {
		
		/**
		*	FactionChat hierarchy:
		*
		*											chatContainer:MovieClip
		*														|
		*							/							|						\
		*	historyChatLog:MovieClip				currentChatLogTextArea:TextArea		chatInputBox:TextArea + 
		*				|																chatState:MovieClip
		*				|
		*	historyChatLogTextArea:TextArea + 
		*	historyChatLogTextAreaScrollBar:ScrollBar
		*
		*
		*	**** Under Stage ****
		*	
		* 	1. chatContainer: Main container for all the chat elements
		*   
		*   **** Under chatContainer ****
		*
		*	1. historyChatLog: Container for history chatlog
		*   2. currentChatLogTextArea: Holding and displaying current chatlog, chatline decay will be applied to this TextArea. 
		*		This TextArea will become visible when the player is not chatting and invisible when the player is chatting
		*	3. chatInputBox: Input box for typing in the chat
		*	4. chatState: Showing 'Say' and 'Team Say' for notifying players the current chat channel
		*	
		* 	**** Under historyChatLog ****
		*
		*	1. historyChatLogTextArea: Holding and displaying ALL history chatlog, chatline decay will NOT be applied to this TextArea
				This TextArea will become visible when the player is chatting and invisible when the player is not chatting
		*	2. historyChatLogTextAreaScrollBar: ScrollBar for historyChatLogTextArea
		*
		*
		*
		*/
		
		
		public var ChatContainer:MovieClip;
		
		public var bTeamChat = false;	
		public var htmlLineBreak:String = "<br />"; // HTML code for line break
		public var msgAliveDuration:int = 10000;   // How long the chat message stays before decay
		public var definedColor:Array = new Array("#CD2323", "#0161ff", "#CCCCCC", "#FF9898","#86EAF6");
		
			// definedColor[0] is red (Red team)
			// definedColor[1] is blue (Blue team)
			// definedColor[2] is grey (Spectator)
			// definedColor[3] is light red (Red team commander)
			// definedColor[4] is light blue (Blue team commander)
		
		// Initialization
		public function FactionsChat() {
			super();
			
			Extensions.enabled = true;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Set all the chat elements invisible
			var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
			historyChatLogContainer.visible = false;
			
			var myChatInputBox:FactionsTextInput = ChatContainer.getChildByName("chatInputBox") as FactionsTextInput;
			myChatInputBox.visible = false;
											
			var myChatState:MovieClip = ChatContainer.getChildByName("chatState") as MovieClip;
			myChatState.visible = false;
			
			// Setup chat input box event listener for listening to Enter key
			myChatInputBox.addEventListener(KeyboardEvent.KEY_DOWN,onInputBoxKeyDown);
		}
		
		// Chat input box key down event, capturing Enter key for sending the chat out
		public function onInputBoxKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER)
			{
				ExternalInterface.call("SendChat", getChatInputBoxText(), this.bTeamChat);
				setChatInputBoxText("");
			}
		}
		
		// Enable chat input box and chat history browsing
		public function enableChatInputBox(chatChannel:String):void {
			if (chatChannel.toLowerCase() == 'team')
				bTeamChat = true;
			else
				bTeamChat = false;
			
			// Make chat input box visible
			var chatInputBox:FactionsTextInput = ChatContainer.getChildByName("chatInputBox") as FactionsTextInput;
			chatInputBox.visible = true;
			chatInputBox.focused = 1;
			
			// Display whether it is team chat
			var chatState:MovieClip = ChatContainer.getChildByName("chatState") as MovieClip;
			chatState.visible = true;
			if (bTeamChat)
				chatState.gotoAndStop(2);
			else
				chatState.gotoAndStop(1);
			
			// Make history chatlog visible and current chatlog invisible
			var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
			currentChatLogTextArea.visible = false;
			var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
			historyChatLogContainer.visible = true;	
			var historyChatLogTextArea:TextArea = historyChatLogContainer.getChildByName("historyChatLogTextArea") as TextArea;
			historyChatLogTextArea.position = 10000;  //Scroll history chat log text area to bottom
		}
		
		// Diable chat input box and chat history browsing
		public function disableChatInputBox():void {
			// Off focus the chat input box by focusing to elsewhere
			var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
			currentChatLogTextArea.focused = 1;
				
			// Make chat input box invisible
			var chatInputBox:FactionsTextInput = ChatContainer.getChildByName("chatInputBox") as FactionsTextInput;
			chatInputBox.visible = false;		
			
			// Make chat state invisible
			var chatState:MovieClip = ChatContainer.getChildByName("chatState") as MovieClip;
			chatState.visible = false;
			
			// Make history chatlog invisible and current chatlog visible
			var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
			historyChatLogContainer.visible = false;
			currentChatLogTextArea.visible = true;
		}
		
		public function getChatInputBoxText():String {
			var myChatInputBox:FactionsTextInput = ChatContainer.getChildByName("chatInputBox") as FactionsTextInput;		
			return myChatInputBox.text;		
		}
		
		public function setChatInputBoxText(setText:String):void{
			var myChatInputBox:FactionsTextInput = ChatContainer.getChildByName("chatInputBox") as FactionsTextInput;		
			myChatInputBox.text = setText;			
		}
		
		// Convert characters: '<' and '>' into HTML code so players won't be able to break the TextArea by inputting HTML elements
		function convertTextToHTML(srcText:String):String{
			var index:int;
			
			// Find '<' first appearance position
			index = srcText.indexOf("<");
			
			var firstHalf:String;
			var secondHalf:String;
			
			// Convert all '<' characters into "&lt;"
			// Loop until no more '<' is found
			while (index != -1)
			{
				firstHalf = "";
				secondHalf = "";
				
				// Use '<' position to break the string into two half like this:
				// first half + '<' + second half
				if (index > 0)
					firstHalf = srcText.substring(0,index-1);
				if (srcText.length > index + 1)
					secondHalf = srcText.substring(index+1,srcText.length);
				
				// Reconnect the string:  first half + "&lt;" + second half			
				srcText = firstHalf + "&lt;" + secondHalf;					
				index = srcText.indexOf("<");						
			}
			
			// Find '>' first appearance position		
			index = srcText.indexOf(">");
			
			// Convert all '<' characters into "&lt;"
			// Loop until no more '<' is found
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
		
		// Add a new chatline to both current chatlog and history chatlog text area
		public function addNewChatLine(chatLine:String, preferedColor:int):void {
			// Temporary string storage for adding the line break and applying appropriate color code to the chatline
			var tempString:String = "";
			
			// Converting '<' and '>' characters into HTML code so players won't be able to input HTML elements
			chatLine = convertTextToHTML(chatLine);
			
			// Add a line break to each chatline
			if (preferedColor >= 0 && preferedColor <= 4)
				tempString = "<font color='" + definedColor[preferedColor] + "'>" + chatLine + "</font>"
								+ htmlLineBreak;
			
			// Append the current chatlog with the chatline
			var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
			currentChatLogTextArea.htmlText += tempString;
			currentChatLogTextArea.position = 10000; // Scroll to the bottom
			
			// Append the history chatlog with the chatline
			var historyChatLogContainer:MovieClip = ChatContainer.getChildByName("historyChatLog") as MovieClip;
			var historyChatLogTextArea:TextArea = historyChatLogContainer.getChildByName("historyChatLogTextArea") as TextArea;
			historyChatLogTextArea.htmlText += tempString;		
			historyChatLogTextArea.position =  10000; // Scroll to the bottom
			
			// Apply chatline decay timer for current chatlog
			var chatLogDecayTimer:Timer = new Timer(msgAliveDuration, 1);
			chatLogDecayTimer.start();
			chatLogDecayTimer.addEventListener(TimerEvent.TIMER, onChatLogDecay);	
			
		}
		
		// Chatline decay, removing the chatline before the first "<br />". The first "<br />" itself will also be removed
		// Chatline decay will only affect current chatlog
		function onChatLogDecay(e:TimerEvent):void {
			var tempString:String = "";
			var currentChatLogTextArea:TextArea = ChatContainer.getChildByName("currentChatLogTextArea") as TextArea;
			var firstLineBreakBeginPosition:int;
			
			// Find the first apperance position of the line break: "<br />"
			firstLineBreakBeginPosition = currentChatLogTextArea.htmlText.indexOf(htmlLineBreak);
			
			// Remove the chatline befre the first "<br />". The first "<br />" itself will also be removed
			if (firstLineBreakBeginPosition)
			{
				if(currentChatLogTextArea.htmlText.length > (firstLineBreakBeginPosition + htmlLineBreak.length))
				{
					tempString = currentChatLogTextArea.htmlText.substring(firstLineBreakBeginPosition + htmlLineBreak.length, currentChatLogTextArea.htmlText.length);
					currentChatLogTextArea.htmlText = tempString;
				}
				else			
					currentChatLogTextArea.htmlText = "";
			}		
		}
	}
}