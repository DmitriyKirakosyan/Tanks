package game.tank {
import com.greensock.TweenMax;

import flash.display.Sprite;

import game.mapObjects.MapObject;
import game.tank.tank_destraction.TankDestoryEvent;
import game.tank.tank_destraction.TankDestroyMethod;
import game.tank.tank_destraction.TankDestroyMethodFactory;

public class Tank extends MapObject {
	public var tankBase:Sprite;
	private var _gunController:TankGunController;
	public var liveTab:LiveTab;
	public var reloadBar:Sprite;

	public var tankUseMouse:Boolean = false;

	private var _vo:TankVO;

	private var _destroyMethod:TankDestroyMethod;

	private var _isPlayer:Boolean;

	private var _speedup:Number = 0;
	private var maxSpeedup:Number = .5;

	public function Tank(vo:TankVO, player:Boolean = false) {
		_isPlayer = player;
		_vo = vo;

		createTankBase();
		_gunController = new TankGunController(_vo.weaponType, this);

		liveTab = new LiveTab();
		this.addChild(liveTab);
		this.addChild(tankBase);
		this.addChild(_gunController.gun);
	}

	public function addReloadController(reloadBar:Sprite):void {
		this.reloadBar = reloadBar;
		reloadBar.x = this.x - this.width/2;
		reloadBar.y = this.y + 20;
		addChild(reloadBar);
	}

	public function updateWeaponType(weaponType:uint):void {
		if (_vo.weaponType != weaponType) {
			_vo.weaponType = weaponType;
			removeChild(_gunController.gun);
			_gunController.updateGun(weaponType);
			addChild(_gunController.gun);
		}
	}

	public function tankDamage():void{
		this.liveTab.scaleX -= .5;
	}

	public function updateLive():void {
		this.liveTab.scaleX = 1;
	}

	public function get vo():TankVO { return _vo; }
	public function get isPlayer():Boolean {return _isPlayer;}
	public function set speedup(value:Number):void {
		value; //TODO refact it
		if (_speedup < maxSpeedup) { _speedup+= .05; }
	}
	public function get speedup():Number { return _speedup; }

	public function get gunController():TankGunController {
		return _gunController;
	}

	public function remove():void {
		if (this.contains(tankBase)) { this.removeChild(tankBase); } else { trace("remove but tankBase not contains [Tank.remove]"); }
		if (this.contains(_gunController.gun)) { this.removeChild(_gunController.gun); }
		if (reloadBar && this.contains(reloadBar)) { this.removeChild(reloadBar); }
	}

	public function bam():void {
		_destroyMethod = TankDestroyMethodFactory.createRandomMethod(this);
		_destroyMethod.addEventListener(TankDestoryEvent.DESTORY_COMPLETE, onDestroyComplete);
		_destroyMethod.destroy();
	}



	public function updateSpeedup():void { _speedup = 0; }

	public function killTweens():void {
		TweenMax.killTweensOf(tankBase);
		_gunController.killGunTweens();
	}

	/* Internal functions */

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