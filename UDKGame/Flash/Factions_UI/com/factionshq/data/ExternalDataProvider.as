package com.factionshq.data {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.external.ExternalInterface;
import scaleform.clik.interfaces.IDataProvider;

[Event(name="change",type="flash.events.Event")]

public class ExternalDataProvider extends EventDispatcher implements IDataProvider {
	
	protected var externalCall:Array;
	
	public function ExternalDataProvider(... args) {
		this.externalCall = args;
	}
	
	public function get data():Array {
		return ExternalInterface.call.apply(null, externalCall) || ["NO DATA (1)", "NO DATA (2)", "NO DATA (3)"];
	}
	
	public function get length():uint {
		return data.length;
	}
	
	public function indexOf(item:Object, callBack:Function = null):int {
		var index:int = data.indexOf(item);
		if (callBack != null) {
			callBack(index);
		}
		return index;
	}
	
	public function requestItemAt(index:uint, callBack:Function = null):Object {
		var item:Object = data[index];
		if (callBack != null) {
			callBack(item);
		}
		return item;
	}
	
	public function requestItemRange(startPosition:int, endPosition:int, callBack:Function = null):Array {
		var items:Array = data.slice(startPosition, endPosition + 1);
		if (callBack != null) {
			callBack(items);
		}
		return items;
	}
	
	public function cleanUp():void {
	}
	
	public function invalidate(length:uint = 0):void {
		super.dispatchEvent(new Event(Event.CHANGE));
	}
}
}
