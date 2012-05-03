/**
 * A data provider that polls UDK for data.
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
	import com.factionshq.interfaces.IDataBuffer;

    [Event(name="change", type="flash.events.Event")]
	
	dynamic public class UDKDataProvider implements IDataProvider, IEventDispatcher {
		
		protected var dataName:String;
		protected var dataBuffer:IDataBuffer;
		protected var dispatcher:EventDispatcher;
		
		public function UDKDataProvider(dataName:String, dataBuffer:IDataBuffer) {
			this.dataName = dataName;
			this.dataBuffer = dataBuffer;
			dispatcher = new EventDispatcher(this);
		}
		
		public function get length():uint {
			fetchData();
			return dataBuffer.length;
		}
		
		public function indexOf(item:Object, callBack:Function=null):int {
			fetchData(callBack, function (data:Array):int {
				return data.indexOf(item);
			});
            
            return 0;
		}
		
		public function requestItemAt(index:uint, callBack:Function=null):Object {
			fetchData(callBack, function (data:Array):Object {
				return data[index];
			});
			
            return null;
    	}
		
		public function requestItemRange(startPosition:int, endPosition:int, callBack:Function=null):Array {
			fetchData(callBack, function (data:Array):Array {
				return data.slice(startPosition, endPosition + 1);
			});
			
            return null;
        }
		
		public function cleanUp():void {
        }
		
		public function invalidate(length:uint=0):void {
            dispatcher.dispatchEvent(new Event(Event.CHANGE));
        }
		
		public function toString():String {
            return "[UDKDataProvider]";
        }
		
		protected function fetchData(callBack:Function=null, dataOperation:Function=null) {
			dataBuffer.onDataReceived(function (data:Array):void {
				if (callBack != null) { callBack(dataOperation(data)); }
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
