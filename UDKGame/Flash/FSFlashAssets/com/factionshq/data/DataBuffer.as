package com.factionshq.data {
	import com.factionshq.interfaces.IDataBuffer;
	
	public class DataBuffer implements IDataBuffer {
		
		private var callBack:Function;
		
		public var data:Array = new Array();
		
		public function get length():uint {
			return data.length;
		}
		
		public function onDataReceived(callBack:Function):void {
			this.callBack = callBack;
		}
		
		public function dataUpdated():void {
			if (callBack != null)
				callBack(data);
		}
	}
}
