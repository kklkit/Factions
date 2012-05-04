/**
 * A data provider that polls an external application for data.
 */
/**************************************************************************

Filename    :   ExternalDataProvider.as

Copyright   :   Copyright 2012 Factions Team. All Rights reserved.

**************************************************************************/

package com.factionshq.data {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
    import scaleform.clik.interfaces.IDataProvider;

    [Event(name="change", type="flash.events.Event")]
	
	public class ExternalDataProvider implements IDataProvider, IEventDispatcher {
		
		protected var dataName:String; // Used to identify what data is being requested when polling the application
		protected var dispatcher:EventDispatcher;
		
		public function ExternalDataProvider(dataName:String) {
			this.dataName = dataName;
			dispatcher = new EventDispatcher(this);
		}
		
		public function get length():uint {
			var data:Array = ExternalInterface.call("GetData", dataName);
			
			return data.length;
		}
		
		public function indexOf(item:Object, callBack:Function=null):int {
			var data:Array = ExternalInterface.call("GetData", dataName);
			var index:int = data.indexOf(item);
			if (callBack != null) { callBack(index); }
            return index;
		}
		
		public function requestItemAt(index:uint, callBack:Function=null):Object {
			var data:Array = ExternalInterface.call("GetData", dataName);
			var item:Object = data[index];
			if (callBack != null) { callBack(item); }
            return item;
    	}
		
		public function requestItemRange(startPosition:int, endPosition:int, callBack:Function=null):Array {
			var data:Array = ExternalInterface.call("GetData", dataName);
			var items:Array = data.slice(startPosition, endPosition + 1);
			if (callBack != null) { callBack(items); }
            return items;
        }
		
		public function cleanUp():void {
        }
		
		public function invalidate(length:uint=0):void {
            dispatcher.dispatchEvent(new Event(Event.CHANGE));
        }
		
		public function toString():String {
        	return "[ExternalDataProvider]";
        }
		 
        public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
            dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        public function dispatchEvent(event:Event):Boolean {
            return dispatcher.dispatchEvent(event);
        }
        public function hasEventListener(type:String):Boolean {
            return dispatcher.hasEventListener(type);
        }
        public function willTrigger(type:String):Boolean {
            return dispatcher.willTrigger(type);
        }
	}
}
