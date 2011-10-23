package game.tank {
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

		private var _autoAttackTimer:Timer;
		private var _targetTank:Tank; //for autoattack mode only
		
		private var _bulletPoint:Point; //coz waiting for gun rotate
		
		public static const LEFT_ROT:int = -90;
		public static const RIGHT_ROT:int = 90;
		public static const UP_ROT:int = 0;
		public static const DOWN_ROT_PLUS:int = 180;
		public static const DOWN_ROT_MINUS:int =-180;
		
		public function TankController(container:Sprite, mapMatrix:MapMatrix):void {
			_scaleTime = 1;

			_movingTimeline = new TimelineMax();
			_direction = new TankDirection(TankDirection.UP_DIR);
			_container = container;
			_mapMatrix = mapMatrix;
		}
		
		public function init(tankVO:TankVO, player:Boolean = false):void {
			tank = new Tank(tankVO, player);
			_container.addChild(tank);
			if (player) {
				tank.x = _mapMatrix.getMatrixPoint(new Point(_startX, _startY)).x;
				tank.y = _mapMatrix.getMatrixPoint(new Point(_startX, _startY)).y;
			}
		}

		public function remove():void {
			TweenMax.killTweensOf(tank);
			tank.killTweens();
			_movingTimeline.kill();
			if (_autoAttackTimer && _autoAttackTimer.running) { _autoAttackTimer.stop(); }
			if (_container.contains(tank)) {
				_container.removeChild(tank);
			}
		}

		public function get tankTimeline():TimelineMax { return _movingTimeline; }
		
		public function scaleTime(value:Number):void {
			_scaleTime = value;
			if (_movingTimeline) {
				_movingTimeline.timeScale = value;
			}
		}
		
		public function isPointOnTank(point:Point):Boolean {
			return tank.hitTestPoint(point.x, point.y);
		}
		
		public function setAutoAttack(targetTank:Tank):void {
			_targetTank = targetTank;
			_autoAttackTimer = new Timer(Math.random() * 3000 + 4000);
			_autoAttackTimer.addEventListener(TimerEvent.TIMER, onAutoAttackTimer);
			_autoAttackTimer.start();
		}
		
		public function bam():void {
			tank.bam();
			TweenMax.killTweensOf(tank);
			if (_autoAttackTimer) { _autoAttackTimer.stop(); }
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
		
		public function shot(point:Point):void {
			_bulletPoint = point;
			tank.gunController.removeTween();
			tank.gunController.addEventListener(GunRotateCompleteEvent.COMPLETE, onGunRotateComplete);
			tank.gunController.gunRotation(_mapMatrix.getMatrixPoint((new Point(point.x, point.y))));
		}

		private function onGunRotateComplete(event:GunRotateCompleteEvent):void {
			tank.gunController.removeEventListener(GunRotateCompleteEvent.COMPLETE,
																						onGunRotateComplete);
			const stageTankPoint:Point = new Point(tank.originX, tank.originY);
			const bullet:Bullet = new Bullet(tank);
			bullet.moveTo(_bulletPoint);
			_container.addChild(bullet);
			dispatchEvent(new TankShotingEvent(TankShotingEvent.WAS_SHOT, bullet));
		}
		
}
}