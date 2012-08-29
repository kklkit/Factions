package com.factionshq.factions {
	import flash.text.*;
	import flash.ui.Keyboard;
	import scaleform.gfx.*;
	import scaleform.clik.controls.TextInput;
	import flash.events.KeyboardEvent;
	
	
	public class FactionsTextInput extends TextInput {
		/**
		*	FactionsTextInput class adds supports for Ctrl+A (Select All), 
		*	Ctrl+C (Copy), Ctrl+V (Paste), Ctrl+X (Cut) for Scaleform TextInput.
		* 
		*	NOTE: TextInput DOES have its native support for these functionalities 
		*	but somehow it only works in GFxMediaPlayer (After pressing F9) and does not work at all in UDK.
		*	This class will become obselete once we find a way around that.
		*
		*	NOTE: For security reasons, FactionsTextInput does not utilize system clipboard, it has its own clipboard
		*/
		
		private var bCtrlDown:Boolean;
		private var clipboard:String;
		
		public function FactionsTextInput() {
			super();
			textField.addEventListener(KeyboardEvent.KEY_DOWN,onTextInputKeyDown);
			textField.addEventListener(KeyboardEvent.KEY_UP,onTextInputKeyUp);
			bCtrlDown = false;
			clipboard = "";
		}
		
		public function onTextInputKeyDown(e:KeyboardEvent) {
			switch(e.keyCode)
			{
				case Keyboard.CONTROL:
				bCtrlDown = true;
				break;
				
				case Keyboard.A:
				if (bCtrlDown)	// Ctrl+A (Select All)
					textField.setSelection(0,textField.length);
				break;				
				
				case Keyboard.C:
				if (bCtrlDown)	// Ctrl+C (Copy)
					copySelectedToClipboard();
				break;
					
				case Keyboard.V:
				if (bCtrlDown)	// Ctrl+V (Paste)
					textField.replaceSelectedText(clipboard);
				break;
					
				case Keyboard.X:
				if (bCtrlDown)	//Ctrl+X (Cut)
				{
					copySelectedToClipboard();
					textField.replaceSelectedText("");
				}
				break;
					
			}
		}
		
		public function onTextInputKeyUp(e:KeyboardEvent) {
			if (e.keyCode == Keyboard.CONTROL)
				bCtrlDown = false;			
		}
		
		private function copySelectedToClipboard() {
			clipboard = textField.text.slice(textField.selectionBeginIndex,textField.selectionEndIndex);
		}			
		
		
	}
}