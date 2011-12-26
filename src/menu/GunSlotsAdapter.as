/**
 * Created by : Dmitry
 * Date: 12/24/11
 * Time: 3:44 PM
 */
package menu {
import com.greensock.TweenLite;
import com.greensock.TweenMax;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

import game.tank.weapon.TankGun;

import menu.TankPodium;

import mx.effects.Glow;

public class GunSlotsAdapter extends Sprite{

	private var _podium:TankPodium;

	private var _leftGun:TankGun;
	private var _rightGun:TankGun;

	private var hiding:Boolean;

	public function GunSlotsAdapter(podium:TankPodium) {
		_podium = podium;
		this.mouseChildren = false;
		createGunSlots();
		hiding = false;
	}

	public function show():void {
		if (hiding) { return; }
		TweenMax.to(_podium.tank.tankBase, .3, {blurFilter:{blurX:10, blurY:10}});
		_podium.container.addChild(this);
		if (!_leftGun) {
			addGuns();
		}
		this.alpha = 0;
		TweenLite.to(this, .3, {alpha: .4});
		this.addEventListener(MouseEvent.ROLL_OUT, onGunSlotRollOut);
		this.addEventListener(MouseEvent.MOUSE_MOVE, onGunSlotMouseMove);
		this.addEventListener(MouseEvent.CLICK, onGunSlotClick);
	}
	public function hide():void {
		removeGunSlots();
	}

	private function addGuns():void {
		if (_podium.tank.vo.weaponType == TankGun.MINIGUN) {
			_leftGun = new TankGun(TankGun.ROCKET);
			_rightGun = new TankGun(TankGun.TAIL_ROCKET);
		} else if (_podium.tank.vo.weaponType == TankGun.ROCKET) {
			_leftGun = new TankGun(TankGun.MINIGUN);
			_rightGun = new TankGun(TankGun.TAIL_ROCKET);
		} else {
			_leftGun = new TankGun(TankGun.ROCKET);
			_rightGun = new TankGun(TankGun.MINIGUN);
		}
		_leftGun.x = -75;
		_leftGun.y = _rightGun.y = 10;
		_rightGun.x = 75;
		this.addChild(_leftGun);
		this.addChild(_rightGun);
	}

	private function createGunSlots():void {
		this.graphics.beginFill(0,.05);
		this.graphics.drawRect(-100, -25, 200, 50);
		this.graphics.endFill();
		this.addChild(new Gantel());
		this.x = _podium.tank.originX;
		this.y = _podium.tank.originY;

	}

	private function onGunSlotRollOut(event:MouseEvent):void {
		removeGunSlots();
	}

	private function onGunSlotClick(event:MouseEvent):void {
		var chosenWeapon:uint;
		if (event.localX > 50) {
			chosenWeapon = _rightGun.type;
		} else if (event.localX < -50) {
			chosenWeapon = _leftGun.type;
		}
		if ((event.localX > 50 || event.localX < -50) && _leftGun) {
			this.removeChild(_leftGun);
			this.removeChild(_rightGun);
			_leftGun = null;
			_rightGun = null;
			_podium.tank.updateGun(chosenWeapon);
			removeGunSlots();
		}
	}

	private function onGunSlotMouseMove(event:MouseEvent):void {
		if (event.localX > 50) {
			_rightGun.filters = [new GlowFilter()];
			_leftGun.filters = [];
		} else if (event.localX < -50) {
			_leftGun.filters = [new GlowFilter()];
			_rightGun.filters = [];
		} else {
			_leftGun.filters = [];
			_rightGun.filters = [];
		}
	}

	private function removeGunSlots():void {
		this.removeEventListener(MouseEvent.ROLL_OUT, onGunSlotRollOut);
		this.removeEventListener(MouseEvent.MOUSE_MOVE, onGunSlotMouseMove);
		this.removeEventListener(MouseEvent.CLICK, onGunSlotClick);
		TweenMax.to(_podium.tank.tankBase, .3, {blurFilter:{blurX:0, blurY:0}});

		hiding = true;
		var thisSlots:GunSlotsAdapter = this;
		TweenLite.to(this, .3, {alpha: 0, onComplete: function():void {
			if (_podium.container.contains(thisSlots)) { _podium.container.removeChild(thisSlots); }
			hiding = false;
		}});
	}

}
}
