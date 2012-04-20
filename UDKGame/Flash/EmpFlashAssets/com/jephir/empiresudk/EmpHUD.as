package com.jephir.empiresudk {
	import flash.display.MovieClip;
	import scaleform.gfx.Extensions;
	
	public class EmpHUD extends MovieClip {
		public var topLeftHUD:MovieClip;
		public var topRightHUD:MovieClip;
		public var bottomLeftHUD:MovieClip;
		public var bottomRightHUD:MovieClip;
		
		public function EmpHUD() {
			Extensions.enabled = true;
		}
	}
}