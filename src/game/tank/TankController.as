package game.tank {
import com.greensock.TimelineLite;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.geom.ColorTransform;

import game.GameController;
import game.TimeController;

import game.events.GunRotateCompleteEvent;

import game.events.TankDestructionEvent;
import game.events.TankShotingEvent;
import game.ControllerWithTime;
import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.geom.Point;

import game.events.TankEvent;
import game.mapObjects.ObjectsHp;
import game.mapObjects.bonus.GameBonus;
import game.matrix.MapMatrix;
import game.tank.weapon.Bullet;
import game.tank.weapon.TankGunController;

import sound.Sounds;

import sound.SoundsManager;

public class TankController extends ControllerWithTime {
	public var tank:Tank;

	private var _scaleTime:Number;

	private var _direction:TankDirection;
	private var _container:Sprite;
	protected var _mapMatrix:MapMatrix;
	private var _wannaShot:Boolean;

	private var _movingTimeline:TimelineMax;
	private var _nextPoint:Point;

	private var _gunController:TankGunController;

	private var _bulletPoint:Point; // waiting for gun rotate

	public static const LEFT_ROT:int = -90;
	public static const RIGHT_ROT:int = 90;
	public static const UP_ROT:int = 0;
	public static const DOWN_ROT_PLUS:int = 180;
	public static const DOWN_ROT_MINUS:int =-180;

	public function TankController(container:Sprite, mapMatrix:MapMatrix):void {
		_scaleTime = 1;
		_wannaShot = true;
		_movingTimeline = new TimelineMax();
		_direction = new TankDirection(TankDirection.UP_DIR);
		_container = container;
		_mapMatrix = mapMatrix;
	}

	protected function get movingTimeline():TimelineMax { return _movingTimeline; }
	public function get wannaShot():Boolean { return _wannaShot; }
	public function get gunController():TankGunController { return _gunController; }

	protected function get container():Sprite { return _container; }

	/**
	 * calls createTank function
	 * @param tankVO -- tank vo
	 */
	public function init(tankVO:TankVO):void {
		createTank(tankVO);
		_gunController = new TankGunController(tank);
		_container.addChild(tank);
	}

	public function tick():void {}

	protected function createTank(tankVO:TankVO):void { //for override
	}

	public function remove():void {
		TweenMax.killTweensOf(tank);
		tank.remove();
		_movingTimeline.kill();
		if (_container.contains(tank)) {
			_container.removeChild(tank);
		}
	}

	override protected function scaleTime(value:Number):void {
		_scaleTime = value;
		if (_movingTimeline) {
			_movingTimeline.timeScale = value;
		}
		_gunController.scaleTime(value);
	}
/*
	public function pause():void {
		if (_movingTimeline) {
			_movingTimeline.pause();
		}
		_gunController.pause();
	}
	public function resume():void {
		if (_movingTimeline) {
			_movingTimeline.resume();
		}
		_gunController.resume();
	}
	*/

	public function isPointOnTank(point:Point):Boolean {
		return tank.hitTestPoint(point.x, point.y);
	}

	public function bam():void {
		TweenMax.killTweensOf(tank);
		tank.bam();
		tank.addEventListener(TankDestructionEvent.TANK_DESTRAYED, onTankDestroyed);
		if (_nextPoint) {
			_mapMatrix.clearTankCell(_nextPoint.x, _nextPoint.y);
		}
	}

	public function readyForMoving():void {
		_movingTimeline.kill();
		_movingTimeline = new TimelineMax({onComplete : onMovingComplete});
		_movingTimeline.stop();
		_movingTimeline.timeScale = _scaleTime;

		//fuck this :(
		clearTankCell();
		var correctedX:int = tank.x < 0 ? tank.x - .5 : tank.x + .5;
		var correctedY:int = tank.y < 0 ? tank.y - .5 : tank.y + .5;
		_mapMatrix.setTankCell(correctedX, correctedY, 1);
	}

	public function setMovingPath(path:Vector.<Point>):void {
		if (!path || path.length == 0) { return; }
		if (!_mapMatrix.isFreeTankCell(path[0].x,  path[0].y)) {
			trace("stop please [TankController.setMovingPath]");
			onMovingComplete();
			return;
		}
		readyForMoving();
		for each (var point:Point in path) {
			addPointToMovePath(point);
		}
	}

	public function addPointToMovePath(point:Point):void {
		if (!point) { return; }
		var speedCoef:Number = _mapMatrix.getSpeedForTank(point);
		if (tank.isPlayer) {
			speedCoef *= Point.distance(new Point(tank.x, tank.y), point);
		}
		_movingTimeline.append(new TweenMax(tank, speedCoef/(tank.vo.speed/5),
					{x : point.x, y : point.y,
					ease : Linear.easeNone,
					onStart : onStartMoveToPathNode,
					onStartParams : [point]}));
		_movingTimeline.play();
		if (_scaleTime != TimeController.NORMAL_TIME_SPEED) {
			_movingTimeline.timeScale = _scaleTime;
		}
	}

	public function setTarget(point:Point = null, rotateGun:Boolean = true):void {
		if (point) { _bulletPoint = point; } //if point is null then we need to shot to same target (_bulletPoint)
		if (!_bulletPoint) { return; }
		if (rotateGun) {
			if (_gunController.rotating) {
				_gunController.removeTween();
				_gunController.removeEventListener(GunRotateCompleteEvent.COMPLETE, onGunRotateComplete);
			}
			_gunController.rotateGun(_bulletPoint);
		}
	}

	public function shot():void {
		if (_gunController.rotating) {
			if (!_gunController.hasEventListener(GunRotateCompleteEvent.COMPLETE)) {
				_gunController.addEventListener(GunRotateCompleteEvent.COMPLETE, onGunRotateComplete);
			}
		} else {
			if (_bulletPoint && !_gunController.reloadController.reloading) {
				ejectBullet();
			}
		}
	}

	public function applyBonus(bonusType:uint):void {
		switch (bonusType) {
			case GameBonus.MEDKIT : tank.updateLive(ObjectsHp.MEDKIT_BONUS);
			case GameBonus.TIME_DEFENSE : tank.addDefense(TankDefense.createTimeDefense());
		}
	}

	/* Internal functions */

	private function onTankDestroyed(event:TankDestructionEvent):void {
		if (!_container.contains(tank)) {
			trace("tank not on container, fix it [TankController.onTankDestoryed]");
			return;
		}
		_container.removeChild(tank);
	}

	protected function onMovingComplete():void {
		dispatchEvent(new TankEvent(TankEvent.MOVING_COMPLETE, this));

//		if (!tank.isPlayer) {
//			SoundsManager.stopSoundByName(Sounds.MOVE);
//		}
	}

	protected function onStartMoveToPathNode(point:Point):void {
		_direction.rotateIfNeed(tank, point, _scaleTime);

		clearTankCell();
		_mapMatrix.setTankCell(point.x,  point.y, 1);
		dispatchEvent(new TankEvent(TankEvent.COME_TO_CELL));
		_nextPoint = point;
		SoundsManager.playSoundByName(Sounds.MOVE);
	}

	private function clearTankCell():void {
		//fuck this please anybody
		if (_nextPoint) {
			_mapMatrix.clearTankCell(_nextPoint.x, _nextPoint.y);
		}
		_mapMatrix.clearTankCell(int(tank.x + .5), int(tank.y + .5));
	}

	private function onGunRotateComplete(event:GunRotateCompleteEvent):void {
		_gunController.removeEventListener(GunRotateCompleteEvent.COMPLETE,onGunRotateComplete);
		if (!_gunController.reloadController.reloading) {
			ejectBullet();
		} else {
			dispatchEvent(new TankShotingEvent(TankShotingEvent.CANT_SHOT, null));
			trace("can not shot [TankController.onGunRotateComplete]");
		}
	}

	private function ejectBullet():void {
		trace("ejectBullet");
		if (tank.destroyed) { return; }
		showShotEffect(_gunController.getBulletPoint(), _gunController.targetRotation);
		const bullet:Bullet = _gunController.createBullet();
		bullet.moveTo(_bulletPoint);
		_container.addChild(bullet);
		dispatchEvent(new TankShotingEvent(TankShotingEvent.WAS_SHOT, bullet));
		_gunController.reloadController.reload();
		_gunController.reloadController.addEventListener(Event.COMPLETE, onReloadComplete);
		_wannaShot = false;
		SoundsManager.playSoundByName(_gunController.getSoundByType(), true);
	}

	private function showShotEffect(point:Point, angle:Number):void {
		var effect:Shot = new Shot();
		effect.x = point.x;
		effect.y = point.y;
		effect.rotation = angle;
		//effect.scaleX = effect.scaleY = .7;
		effect.alpha = .3;
		_container.addChild(effect);
		var timeline:TimelineLite = new TimelineLite({onComplete : function():void {_container.removeChild(effect); }});
		timeline.append(TweenMax.to(effect, .001, {glowFilter:{color:0xFF0000, alpha: 1, blurX: 3, strength : 10, blurY: 3}}));
		timeline.append(TweenLite.to(effect, .3, {alpha: .3}));
	}

	private function onReloadComplete(event:Event):void {
		_gunController.reloadController.removeEventListener(Event.COMPLETE, onReloadComplete);
		_wannaShot = true;
		dispatchEvent(new TankShotingEvent(TankShotingEvent.RELOAD_COMPLETE, null));
	}

}
}