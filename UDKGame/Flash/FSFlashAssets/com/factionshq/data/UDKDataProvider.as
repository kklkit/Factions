/**
 * A data provider that polls UDK.
 */
/**************************************************************************

Filename    :   UDKDataProvider.as

Copyright   :   Copyright 2012 Factions Team. All Rights reserved.

**************************************************************************/

package com.factionshq.data {
	
	import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.Event;
   	import flash.external.ExternalInterface;
		
    import scaleform.clik.interfaces.IDataProvider;

    [Event(name="change", type="flash.events.Event")]
	
	dynamic public class UDKDataProvider implements IDataProvider, IEventDispatcher {
		
		private var dataName:String;
		
		protected var dispatcher:EventDispatcher;
		
		public function UDKDataProvider(dataName) {
			dispatcher = new EventDispatcher(this);
			this.dataName = dataName;
		}
		
		public function indexOf(item:Object, callBack:Function=null):int {
            var index:int = udkIndexOf(dataName, item as String);
            if (callBack != null) { callBack(index); }
            return index;
		}
		
		public function requestItemAt(index:uint, callBack:Function=null):Object {
            var item:Object = udkRequestItemAt(dataName, index);
            if (callBack != null) { callBack(item); }
            return item;
    	}
		
		public function requestItemRange(startPosition:int, endPosition:int, callBack:Function=null):Array {
            var items:Array = udkRequestItemRange(dataName, startPosition, endPosition);
            if (callBack != null) { callBack(items); }
            return items;
        }
		
		public function cleanUp():void {
            udkCleanUp();
        }
		
		public function invalidate(length:uint=0):void {
            // The length parameter is in the Array DataProvider for compatibility purposes, and is not used.
            dispatcher.dispatchEvent(new Event(Event.CHANGE));
        }
		
		public function toString():String {
            return "[CLIK UDKDataProvider]";
        }
		
	// EventDispatcher Mix-in    
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
