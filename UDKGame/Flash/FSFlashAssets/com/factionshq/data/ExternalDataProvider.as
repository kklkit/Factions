/**
 * A data provider that polls an external application for data.
 *
 * Users of this data provider should always use the callbacks since the function return values are cached and may be out-of-date. Callback values will always be up-to-date as returned by the external application.
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
		protected var dataBuffer:DataBuffer; // Contains the requested data
		protected var dispatcher:EventDispatcher;
		
		public function ExternalDataProvider(dataName:String, dataBuffer:DataBuffer) {
			this.dataName = dataName;
			this.dataBuffer = dataBuffer;
			dispatcher = new EventDispatcher(this);
		}
		
		public function get length():uint {
			fetchData();
			return dataBuffer.data.length;
		}
		
		public function indexOf(item:Object, callBack:Function=null):int {
			fetchData(callBack, function (data:Array):int {
				return data.indexOf(item);
			});
            
            return dataBuffer.data.indexOf(item);
		}
		
		public function requestItemAt(index:uint, callBack:Function=null):Object {
			fetchData(callBack, function (data:Array):Object {
				return data[index];
			});
			
            return dataBuffer.data[index];
    	}
		
		public function requestItemRange(startPosition:int, endPosition:int, callBack:Function=null):Array {
			fetchData(callBack, function (data:Array):Array {
				return data.slice(startPosition, endPosition + 1);
			});
			
            return dataBuffer.data.slice(startPosition, endPosition + 1);
        }
		
		public function cleanUp():void {
			dataBuffer.data.splice(0, dataBuffer.data.length);
        }
		
		public function invalidate(length:uint=0):void {
            dispatcher.dispatchEvent(new Event(Event.CHANGE));
        }
		
		public function toString():String {
        	return "[ExternalDataProvider " + dataBuffer.data.join(",") + "]";
        }
		
		protected function fetchData(callBack:Function=null, dataOperation:Function=null) {
			dataBuffer.onDataReceived(function (data:Array):void {
				if (callBack != null && dataOperation != null) { callBack(dataOperation(data)); }
			});
			
			ExternalInterface.call("GetData", dataName);
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
