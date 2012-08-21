package com.factionshq.utils {
	public class Misc {
		public static function lerp(value1:Number, value2:Number, amount:Number):Number {
			return value1 + (value2 - value1) * amount;
		}
		
		public static function zeroPad(number:int, width:int):String {
			var ret:String = "" + number;
			while (ret.length < width)
				ret = "0" + ret;
			return ret;
		}
	}
}