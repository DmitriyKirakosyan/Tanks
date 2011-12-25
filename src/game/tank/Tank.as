package game.tank {
import com.greensock.TweenMax;

import flash.display.DisplayObject;

import flash.display.Sprite;
import flash.filters.GlowFilter;

import game.events.TankDestructionEvent;

import game.mapObjects.MapObject;
import game.mapObjects.ObjectsHp;
import game.tank.TankBotController;
import game.tank.ability.TankAbility;
import game.tank.destruction.TankDestroyMethod;
import game.tank.destruction.TankDestroyMethod;
import game.tank.destruction.TankDestroyMethodFactory;
import game.tank.weapon.TankGun;

import menu.TankPodium;

public class Tank extends MapObject {
	private var _gun:TankGun;
	public var _defense:TankDefense;
	private var _tankBase:Sprite;
	private var _liveTab:LiveBar;
	private var _liveTabBckg:LiveBar;
	public var reloadBar:Sprite;

	private var _vo:TankVO;

	private var _destroyMethod:TankDestroyMethod;

	private var _isPlayer:Boolean;

	private var _speedup:Number = 0;
	private var maxSpeedup:Number = .5;

	public static function createBotTank(vo:TankVO, strength:uint):Tank {
        vo.tankBase = strength + 2;
		var hp:Number = strength == TankBotController.BASE_BOT ? ObjectsHp.FIST_BOT :
										strength == TankBotController.ADVANCE_BOT ? ObjectsHp.SECOND_BOT : ObjectsHp.THIRD_BOT;
		var tank:Tank = new Tank(vo, false, hp);
		return tank;
	}

	public static function createPlayerTank(vo:TankVO):Tank {
		return new Tank(vo, true, vo.hp);
	}
	//TODO LiveTab
	public function Tank(vo:TankVO, isPlayer:Boolean, hp:Number) {
		_isPlayer = isPlayer;
		setHp(hp);
		_vo = vo;
		createTankBase();
		addGun(new TankGun(vo.weaponType));
		createLiveBar();
		this.addChild(_liveTabBckg);
		this.addChild(_liveTab);
	}

	private function createLiveBar():void {
		_liveTab = new LiveBar();
		_liveTabBckg = new LiveBar();
		_liveTab.scaleY =  .6; _liveTabBckg.scaleY = .6;
		_liveTab.y = -18; _liveTabBckg.y = -18;
		_liveTab.x = _liveTab.x - _liveTab.width/2; _liveTabBckg.x = _liveTabBckg.x - _liveTabBckg.width/2;
		_liveTabBckg.alpha = .18;
	}

	//for destroy methods
//	public function hide():void {
//		_gun.visible = false;
//		_tankBase.visible = false;
//	}

	public function get gun():TankGun { return _gun; }
	public function get tankBase():Sprite { return _tankBase; }
	public function get liveTab():LiveBar { return _liveTab; }
	public function get liveTabBckg():LiveBar { return _liveTabBckg; }
	
	public function get ability():uint { return _vo.ability; }

	public function get baseRotation():Number { return _tankBase.rotation; }

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
		if (_gun && this.contains(_gun)) { this.removeChild(_gun); }
		addGun(new TankGun(weaponType));
	}
	public function updateBase(baseType:uint):void {
		_vo.tankBase = baseType;
		if (_tankBase && this.contains(_tankBase)) { this.removeChild(_tankBase); }
		createTankBase();
		if (baseType == TankVO.TANK_BASE_2) {
			_vo.speed = TankVO.SECOND_SPEED;
			_vo.hp = ObjectsHp.PLAYER_SECOND;
		}
	}

	public function addReloadBar(reloadBar:Sprite):void {
		this.reloadBar = reloadBar;
		reloadBar.x = this.x - this.width/2-5;
		reloadBar.y = this.y + 25;
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
		killTweens();
		if (this.contains(_tankBase)) { this.removeChild(_tankBase); } else { trace("remove but tankBase not contains [Tank.remove]"); }
		if (this.contains(_gun)) { this.removeChild(_gun); }
		if (reloadBar && this.contains(reloadBar)) { this.removeChild(reloadBar); }
		if (_destroyMethod) { _destroyMethod.stopDestroying(); }
	}

	public function bam():void {
		_destroyMethod = TankDestroyMethodFactory.createMethodById(0, this);
		_destroyMethod.addEventListener(TankDestructionEvent.TANK_DESTRAYED, onDestroyComplete);
		_destroyMethod.destroy();
		if (_liveTab && this.contains(_liveTab)) { this.removeChild(_liveTab); }
	}

	override public function hitTestObject(object:DisplayObject):Boolean {
		return _tankBase.hitTestObject(object) || _gun.hitTestObject(object);
	}

	public function updateSpeedup():void { _speedup = 0; }

	/* Internal functions */

	private function killTweens():void {
		TweenMax.killTweensOf(_tankBase);
	}

	private function addGun(gun:TankGun):void {
		_gun = gun;
		gun.rotation = _tankBase.rotation;
		this.addChild(gun);
	}

	private function createTankBase():void {
		if (_vo.tankBase < TankPodium.VALID_TANK_BASES.length) {
			_tankBase = new TankPodium.VALID_TANK_BASES[_vo.tankBase];
            _tankBase.filters = [new GlowFilter(0)];
		}		this.addChildAt(_tankBase, 0);
	}

	private function onDestroyComplete(event:TankDestructionEvent):void {
		_destroyMethod.removeEventListener(TankDestructionEvent.TANK_DESTRAYED, onDestroyComplete);
		dispatchEvent(new TankDestructionEvent(TankDestructionEvent.TANK_DESTRAYED));
		trace("[Tank.onDestroyComplete] me destroed");
	}
}
}