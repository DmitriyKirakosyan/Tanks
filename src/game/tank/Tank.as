package game.tank {
import com.greensock.TweenMax;

import flash.display.Sprite;

import game.mapObjects.MapObject;
import game.tank.tank_destraction.TankDestoryEvent;
import game.tank.tank_destraction.TankDestroyMethod;
import game.tank.tank_destraction.TankDestroyMethodFactory;

public class Tank extends MapObject {
	public var _gun:TankGun;
	public var _defense:TankDefense;
	public var tankBase:Sprite;
	private var _liveTab:LiveTab;
	public var reloadBar:Sprite;

	private var _vo:TankVO;

	private var _destroyMethod:TankDestroyMethod;

	private var _isPlayer:Boolean;

	private var _speedup:Number = 0;
	private var maxSpeedup:Number = .5;

	public function Tank(vo:TankVO, player:Boolean = false) {
		_isPlayer = player;
		_vo = vo;

		createTankBase();
		addGun(new TankGun(vo.weaponType));

		_liveTab = new LiveTab();
		this.addChild(_liveTab);
		this.addChild(tankBase);
	}

	public function get gun():TankGun {
		return _gun;
	}

	public function isDead():Boolean {
		return _liveTab.scaleX == 0;
	}

	public function addDefense(defense:TankDefense):void {
		if (defense) {
			if (_defense) {
				if (this.contains(_defense)) { this.removeChild(_defense); }
			}
			_defense = defense;
			this.addChild(_defense);
		}
	}

	public function updateGun(weaponType:uint):void {
		_vo.weaponType = weaponType;
		addGun(new TankGun(weaponType));
	}
	public function removeGun():void {
		if (_gun && this.contains(_gun)) { this.removeChild(_gun); }
		_gun = null;
	}

	public function addReloadBar(reloadBar:Sprite):void {
		this.reloadBar = reloadBar;
		reloadBar.x = this.x - this.width/2;
		reloadBar.y = this.y + 20;
		addChild(reloadBar);
	}

	public function tankDamage():void{
		_liveTab.scaleX -= .5;
		if (_liveTab.scaleX < 0) { _liveTab.scaleX = 0; }
	}

	public function updateLive():void {
		_liveTab.scaleX = 1;
	}

	public function get vo():TankVO { return _vo; }
	public function get isPlayer():Boolean {return _isPlayer;}
	public function set speedup(value:Number):void {
		value; //TODO refact it
		if (_speedup < maxSpeedup) { _speedup+= .05; }
	}
	public function get speedup():Number { return _speedup; }

	public function remove():void {
		if (this.contains(tankBase)) { this.removeChild(tankBase); } else { trace("remove but tankBase not contains [Tank.remove]"); }
		if (this.contains(_gun)) { this.removeChild(_gun); }
		if (reloadBar && this.contains(reloadBar)) { this.removeChild(reloadBar); }
	}

	public function bam():void {
		_destroyMethod = TankDestroyMethodFactory.createRandomMethod(this);
		_destroyMethod.addEventListener(TankDestoryEvent.DESTORY_COMPLETE, onDestroyComplete);
		_destroyMethod.destroy();
		if (_liveTab && this.contains(_liveTab)) { this.removeChild(_liveTab); }
	}



	public function updateSpeedup():void { _speedup = 0; }

	public function killTweens():void {
		TweenMax.killTweensOf(tankBase);
	}

	/* Internal functions */

	private function addGun(gun:TankGun):void {
		_gun = gun;
		this.addChild(gun);
	}

	private function createTankBase():void {
		if (_vo.tankBase == 0) {
			tankBase = new TankBaseView();
		} else {
			tankBase = new Sprite();
			const brickView:BricksView = new BricksView();
			brickView.x -= brickView.width/2;
			brickView.y -= brickView.height/2;
			tankBase.addChild(brickView);
		}
	}

	private function onDestroyComplete(event:TankDestoryEvent):void {
		_destroyMethod.removeEventListener(TankDestoryEvent.DESTORY_COMPLETE, onDestroyComplete);
		trace("[Tank.onDestroyComplete] me destroed");
	}

		
	}
}