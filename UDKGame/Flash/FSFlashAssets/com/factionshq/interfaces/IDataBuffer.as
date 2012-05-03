/** 
 * Interface for a data buffer object.
 */
/**************************************************************************

Filename    :   IDataBuffer.as

Copyright   :   Copyright 2012 Factions Team. All Rights reserved.

**************************************************************************/

package com.factionshq.interfaces {
	
	public interface IDataBuffer {
		function get length():uint;
		function onDataReceived(callBack:Function):void;
		function dataUpdated():void;
	}
}
