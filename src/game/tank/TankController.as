package game.tank {
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import game.events.GunRotateCompleteEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import game.events.TankShotingEvent;
	import game.IControllerWithTime;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import game.events.TankEvent;
	import game.matrix.MapMatrix;

	public class TankController extends EventDispatcher implements IControllerWithTime{
		public var tank:Tank;
		
		private var _scaleTime:Number;
		
		private var _direction:TankDirection;
		private var _container:Sprite;
		private var _mapMatrix:MapMatrix;
		
		private var _startX:Number = 300;
		private var _startY:Number = 300;
		
		private var _movingTimeline:TimelineMax;
		
		private var _reloadController:GunReloadController;
		private var _gunController:TankGunController;

		private var _autoAttackTimer:Timer;
		private var _targetTank:Tank; //for autoattack mode only
		
		private var _bulletPoint:Point; // waiting for gun rotate
		
		private var _canShot:Boolean;
		
		public static const LEFT_ROT:int = -90;
		public static const RIGHT_ROT:int = 90;
		public static const UP_ROT:int = 0;
		public static const DOWN_ROT_PLUS:int = 180;
		public static const DOWN_ROT_MINUS:int =-180;
		
		public function TankController(container:Sprite, mapMatrix:MapMatrix):void {
			_scaleTime = 1;
			_movingTimeline = new TimelineMax();
			_reloadController = new GunReloadController();
			_direction = new TankDirection(TankDirection.UP_DIR);
			_container = container;
			_mapMatrix = mapMatrix;
		}
		
		public function get movingTimeline():TimelineMax { return _movingTimeline; }
		
		public function updateWeaponType(weaponType:uint):void {
			tank.removeGun();
			_gunController.updateWeaponType(weaponType);
			tank.addGun(_gunController.gun);
		}

		public function init(tankVO:TankVO, player:Boolean = false):void {
			tank = new Tank(tankVO, player);
			_gunController = new TankGunController(tankVO.weaponType, tank);
			tank.addGun(_gunController.gun);
			if (player) {
				highlightPlayerTank();
			}
			_reloadController.reloadBar.y = tank.originY + 30;
			_reloadController.reloadBar.x = tank.originX - tank.width/2;
			tank.addReloadController(_reloadController.reloadBar);
			_container.addChild(tank);
			_canShot = true;
		}

		public function remove():void {
			_canShot = false;
			TweenMax.killTweensOf(tank);
			tank.killTweens();
			_movingTimeline.kill();
			if (_autoAttackTimer && _autoAttackTimer.running) { _autoAttackTimer.stop(); }
			if (_container.contains(tank)) {
				_container.removeChild(tank);
			}
			_container.removeChild(_reloadController.reloadBar);
		}

		public function get tankTimeline():TimelineMax { return _movingTimeline; }
		
		public function scaleTime(value:Number):void {
			_scaleTime = value;
			if (_movingTimeline) {
				_movingTimeline.timeScale = value;
			}
			if (_reloadController.reloading) {
				_reloadController.scaleTime(value);
			}
		}
		
		public function isPointOnTank(point:Point):Boolean {
			return tank.hitTestPoint(point.x, point.y);
		}
		
		public function setAutoAttack(targetTank:Tank):void {
			_targetTank = targetTank;
			_autoAttackTimer = new Timer(Math.random() * 5000 + 1000);  //TODO Auto attack
			_autoAttackTimer.addEventListener(TimerEvent.TIMER, onAutoAttackTimer);
			_autoAttackTimer.start();
		}
		
		public function get autoAttackTimer():Timer { return _autoAttackTimer; }
		
		public function bam():void {
			TweenMax.killTweensOf(tank);
			if (_autoAttackTimer) { _autoAttackTimer.stop(); }
			tank.bam();
		}
		
		public function readyForMoving():void {
			tank.updateSpeedup();
			_movingTimeline.kill();
			_movingTimeline = new TimelineMax({onComplete : onMovingComplete});
			_movingTimeline.timeScale = _scaleTime;
		}
		
		public function addPointToMovePath(point:Point):void {
			if (!point) { return; }
			const speedCoef:Number = _mapMatrix.getSpeedForTank(point);
			_movingTimeline.append(new TweenMax(tank, speedCoef * (.9 - tank.speedup--), 
						{x : point.x, y : point.y, 
						ease : Linear.easeNone,
						onStart : onStartMoveToPathNode,
						onStartParams : [point]}));
			_movingTimeline.play();
		}
		
		public function shot(point:Point):void {
			_bulletPoint = point;
			if (_gunController.rotating) {
				_gunController.removeTween();
				_gunController.removeEventListener(GunRotateCompleteEvent.COMPLETE, onGunRotateComplete);
			}
			_gunController.addEventListener(GunRotateCompleteEvent.COMPLETE, onGunRotateComplete);
			_gunController.rotateGun(_mapMatrix.getMatrixPoint((new Point(point.x, point.y))));
		}

		/* Internal functions */
		
		private function onAutoAttackTimer(event:TimerEvent):void {
			if (_targetTank) {
				shot(new Point(_targetTank.originX, _targetTank.originY));
			}
		}
		
		private function onMovingComplete():void {
			dispatchEvent(new TankEvent(TankEvent.MOVING_COMPLETE, this));
		}
		
		private function onStartMoveToPathNode(point:Point):void {
			_direction.rotateIfNeed(tank, point);
			dispatchEvent(new TankEvent(TankEvent.COME_TO_CELL));
		}
		
		private function onGunRotateComplete(event:GunRotateCompleteEvent):void {
			_gunController.removeEventListener(GunRotateCompleteEvent.COMPLETE,onGunRotateComplete);
			if (_canShot) {
				const bullet:Bullet = _gunController.createBullet();
				bullet.moveTo(_bulletPoint);
				bullet.setPosition(_gunController.getBulletPoint());
				bullet.rotation = _gunController.gunRot;
				_container.addChild(bullet);
				dispatchEvent(new TankShotingEvent(TankShotingEvent.WAS_SHOT, bullet));
				_canShot = false;
				_reloadController.reload();
				_reloadController.addEventListener(Event.COMPLETE, onReloadComplete);
			} else {
				dispatchEvent(new TankShotingEvent(TankShotingEvent.CANT_SHOT, null));
				trace("can not shot [TankController.onGunRotateComplete]");
			}
		}
		
		private function onReloadComplete(event:Event):void {
			_reloadController.removeEventListener(Event.COMPLETE, onReloadComplete);
			_canShot = true;
		}

		private function highlightPlayerTank():void {
			var colorTank:ColorTransform = new ColorTransform;
			colorTank.color = 0x0000ff;
			tank.x = _mapMatrix.getMatrixPoint(new Point(_startX, _startY)).x;
			tank.y = _mapMatrix.getMatrixPoint(new Point(_startX, _startY)).y;
			tank.tankBase.transform.colorTransform = colorTank;
		}
	}
}