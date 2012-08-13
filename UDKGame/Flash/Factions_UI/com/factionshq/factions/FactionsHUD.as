package com.factionshq.factions {

import fl.motion.*;
import flash.display.*;
import flash.events.*;
import flash.external.*;
import flash.geom.*;
import flash.text.*;
import scaleform.gfx.*;

public class FactionsHUD extends MovieClip {
	public var centerHUD:MovieClip;
	public var bottomLeftHUD:MovieClip;
	public var bottomRightHUD:MovieClip;
	
	public var healthBarStartPositionX:Number = bottomLeftHUD.getChildByName('healthBar').x;
	public var staminaBarStartPositionX:Number = bottomLeftHUD.getChildByName('staminaBar').x;
	public var ammoBarStartPositionX:Number = bottomRightHUD.getChildByName('ammoBar').x;
	public var targetHealthBarStartWidth:Number = centerHUD.getChildByName('targetHealthBar').width;
	
	public function FactionsHUD() {
		super();
		
		Extensions.enabled = true;
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.RESIZE, function() {
				ExternalInterface.call("ResizeHUD");
			});
		
		ExternalInterface.call("ResizeHUD");
	}
	
	public function updateResolution(x0:Number, y0:Number, x1:Number, y1:Number) {
		centerHUD.x = x1 / 2;
		centerHUD.y = y1 / 2;
		bottomLeftHUD.y = y1;
		bottomRightHUD.y = y1;
		bottomRightHUD.x = x1;
	}
	
	public function updateTargetHealth(health:int, healthMax:int) {
		var healthBar:DisplayObject = centerHUD.getChildByName('targetHealthBar');
		
		healthBar.width = health / healthMax * targetHealthBarStartWidth;
	}
	
	public function showTargetHealth(show:Boolean) {
		var healthBar:DisplayObject = centerHUD.getChildByName('targetHealthBar');
		var healthBarBox:DisplayObject = centerHUD.getChildByName('targetHealthBarBox');
		
		healthBar.visible = healthBarBox.visible = show;
	}
	
	public function updateHealth(health:int, healthMax:int):void {
		var healthBar:DisplayObject = bottomLeftHUD.getChildByName('healthBar');
		
		// Check for divide by zero
		if (healthMax === 0) {
			health = 0;
			healthMax = 1;
		}
		
		healthBar.x = -healthBar.width + healthBarStartPositionX + (health / healthMax * healthBar.width);
	}
	
	public function updateStamina(stamina:int, staminaMax:int):void {
		var staminaBar:DisplayObject = bottomLeftHUD.getChildByName('staminaBar');
		
		// Check for divide by zero
		if (staminaMax === 0) {
			stamina = 0;
			staminaMax = 1;
		}
		
		staminaBar.x = -staminaBar.width + staminaBarStartPositionX + (stamina / staminaMax * staminaBar.width);
	}
	
	public function updateAmmo(ammo:int, ammoMax:int):void {
		var ammoBar:DisplayObject = bottomRightHUD.getChildByName('ammoBar');
		
		// Check for divide by zero
		if (ammoMax === 0) {
			ammo = 0;
			ammoMax = 1;
		}
		
		ammoBar.x = ammoBar.width + ammoBarStartPositionX - (ammo / ammoMax * ammoBar.width);
	}
	
	public function updateMagazineCount(mags:int):void {
		var magCount:TextField = bottomRightHUD.getChildByName('magCount') as TextField;
		magCount.text = mags.toString();
	}
	
	public function updateVehicleHealth(health:int, healthMax:int):void {
		var vehicleBody:DisplayObject = bottomLeftHUD.getChildByName('vehicleBody');
		var colorInfo:ColorTransform = vehicleBody.transform.colorTransform;
		var percent:Number = health / healthMax;
		
		if (percent > 0.5) {                      
            colorInfo.color = Color.interpolateColor(0xffff00, 0x00ff00, (percent - 0.5) / 0.5);
        } else {
            colorInfo.color = Color.interpolateColor(0xff0000, 0xffff00, percent / 0.5);
        }
		
		vehicleBody.transform.colorTransform = colorInfo;
	}
	
	public function updateVehicleRotation(rotation:int):void {
		var vehicleBody:DisplayObject = bottomLeftHUD.getChildByName('vehicleBody');
		vehicleBody.rotation = rotation;
	}
	
	public function showVehicleHUD(showHUD:Boolean):void {
		var vehicleBody:DisplayObject = bottomLeftHUD.getChildByName('vehicleBody');
		var vehicleTurret:DisplayObject = bottomLeftHUD.getChildByName('vehicleTurret');
		
		vehicleBody.visible = showHUD;
		vehicleTurret.visible = showHUD;
	}
}
}