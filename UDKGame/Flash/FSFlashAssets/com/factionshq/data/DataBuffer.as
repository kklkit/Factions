/**
 * Buffer used by the external application to provide data to Scaleform.
 *
 * The external application should update the "data" property with the requested data once the "GetData" external interface call has been made from the ExternalDataProvider. Once the data has been updated, the "dataUpdated" function must be called to signal the ExternalDataProvider to use the new data.
 */
/**************************************************************************

Filename    :   DataBuffer.as

Copyright   :   Copyright 2012 Factions Team. All Rights reserved.

**************************************************************************/

package com.factionshq.data {
	
	public class DataBuffer {
		
		private var callBack:Function;
		
		public var data:Array = new Array(); // This property should be updated by the external application to contain the requested data
		
		public function onDataReceived(callBack:Function):void {
			this.callBack = callBack;
		}
		
		public function dataUpdated():void {
			if (callBack != null)
				callBack(data);
		}
	}
}
