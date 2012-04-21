package com.jephir.empiresudk {
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.external.ExternalInterface;
	import scaleform.gfx.Extensions;
	import flash.events.Event;
	
	public class EmpHUD extends MovieClip {
		public var topLeftHUD:MovieClip;
		public var topRightHUD:MovieClip;
		public var bottomLeftHUD:MovieClip;
		public var bottomRightHUD:MovieClip;
		
		public function EmpHUD() {
			Extensions.enabled = true;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(Event.RESIZE, function () {
				ExternalInterface.call("ResizeHUD");
			});
		}
	}
}