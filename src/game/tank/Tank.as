package game.tank {
import com.greensock.TweenMax;

import flash.display.Sprite;

import game.events.TankDestructionEvent;

import game.mapObjects.MapObject;
import game.mapObjects.ObjectsHp;
import game.tank.ability.TankAbility;
import game.tank.destruction.TankDestroyMethod;
import game.tank.destruction.TankDestroyMethodFactory;
import game.tank.weapon.TankGun;

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

	public static function createBotTank(vo:TankVO, strength:uint):Tank {
		var hp:Number = strength == TankBotController.BASE_BOT ? ObjectsHp.FIST_BOT :
										strength == TankBotController.ADVANCE_BOT ? ObjectsHp.SECOND_BOT : ObjectsHp.THIRD_BOT;
		return new Tank(vo, false, hp);
	}

	public static function createPlayerTank(vo:TankVO):Tank {
		return new Tank(vo, true, ObjectsHp.PLAYER);
	}

	public function Tank(vo:TankVO, isPlayer:Boolean, hp:Number) {
		_isPlayer = isPlayer;
		setHp(hp);
		_vo = vo;

		createTankBase();
		addGun(new TankGun(vo.weaponType));

		_liveTab = new LiveTab();
		_liveTab.scaleY = .6;
		_liveTab.y = -18;
		this.addChild(_liveTab);
		this.addChildAt(tankBase, 0);
	}

	//for destroy methods
	public function hide():void {
		_gun.alpha -=10;
		tankBase.alpha -= 10;
		//_gun.visible = false;
		//tankBase.visible = false;
	}

	public function get gun():TankGun {
		return _gun;
	}
	public function get liveTab():LiveTab { return _liveTab; }
	
	public function get ability():uint { return _vo.ability; }

	public function get baseRotation():Number { return tankBase.rotation; }

	public function hasDefence():Boolean { return _defense != null; }

	public function isDead():Boolean {
		return _liveTab.scaleX == 0;
	}

	public function addDefense(defense:TankDefense):void {
		if (defense) {
			if (_defense) {
				TweenMax.killTweensOf(_defense);
				if (this.contains(_defense)) { this.removeChild(_defense); }
			}
			_defense = defense;
			this.addChild(_defense);
			var thisTank:Tank = this;
			TweenMax.to(_defense, 2, { alpha : 0, onComplete: function():void {
				if (thisTank.contains(_defense)) {
					if (thisTank.contains(_defense)) {
						thisTank.removeChild(_defense);
					}
				}
				_defense = null;
			}});
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

	override public function damage(value:Number):void{
		super.damage(value);
		_liveTab.scaleX = hp/maxHp;
	}

	public function updateLive(value:Number):void {
		super.plusHp(value);
		_liveTab.scaleX = hp/maxHp;
	}

	public function get vo():TankVO { return _vo; }
	public function get isPlayer():Boolean {return _isPlayer;}
	public function set isPlayer(value:Boolean):void { _isPlayer = value; }
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
		_destroyMethod.addEventListener(TankDestructionEvent.TANK_DESTRAYED, onDestroyComplete);
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
			tankBase = new TankBase1();
		} else {
			tankBase = new Sprite();
			const baseView:TankBase2 = new TankBase2();
			tankBase.addChild(baseView);
		}
	}

	private function onDestroyComplete(event:TankDestructionEvent):void {
		_destroyMethod.removeEventListener(TankDestructionEvent.TANK_DESTRAYED, onDestroyComplete);
		dispatchEvent(new TankDestructionEvent(TankDestructionEvent.TANK_DESTRAYED));
		trace("[Tank.onDestroyComplete] me destroed");
	}
}
}