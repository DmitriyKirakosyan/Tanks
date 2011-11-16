package game.tank {
import com.greensock.easing.Linear;

import flash.geom.Point;
import com.greensock.TweenMax;
import flash.display.Sprite;

public class Bullet extends Sprite {
	private var _tween:TweenMax;
	private var _speed:Number;
	private var _selfTank:Tank;

	private var _tailPeriodCounter:int;

	private var _container:Sprite;


	private var speedCoef:Number = 200;
	private const TAIL_PERIOD:int = 1;

	public function Bullet(selfTank:Tank):void {
		_tailPeriodCounter = 0;
		_selfTank = selfTank;
		drawBulletPointOn(this, 0xf0002f);
		this.rotation = selfTank.gunController.gunRot;
		const bulletPoint:Point = selfTank.gunController.getBulletPoint();
		this.x = bulletPoint.x;
		this.y = bulletPoint.y;
	}

	public function get selfTank():Tank { return _selfTank; }

	public function setContainer(container:Sprite):void {
		_container = container;
	}

	public function updateEffect():void {
		tickTailPeriod();
		if (timeToTail) { drawTail(); }
	}

	private function drawTail():void {
		var bulletTailPart:Sprite = new Sprite();
		this.drawBulletPointOn(bulletTailPart);
		bulletTailPart.x = this.x;
		bulletTailPart.y = this.y;
		bulletTailPart.scaleX = bulletTailPart.scaleY = .1;
		bulletTailPart.alpha = .6;
		_container.addChild(bulletTailPart);
		TweenMax.to(bulletTailPart, 1.5, { scaleX : 3, scaleY : 3, alpha : 0, ease : Linear.easeNone,
									onComplete: function():void { _container.removeChild(bulletTailPart); } });
	}

	private function tickTailPeriod():void {
		_tailPeriodCounter++;
		if (_tailPeriodCounter >= TAIL_PERIOD) { _tailPeriodCounter = 0; }
	}

	public function get timeToTail():Boolean { return _tailPeriodCounter == 0; }

	public function moveTo(point:Point):void {
		if (_selfTank.isPlayer) { speedCoef = 200; }
		else { speedCoef = 100; }
		_speed = Math.sqrt(Math.pow(this.x-point.x, 2) + Math.pow(this.y - point.y, 2)) / speedCoef;
		_tween = new TweenMax(this, _speed, {x : point.x, y : point.y, ease : Linear.easeNone} );
	}

	public function remove():void {
		_tween.vars["onComplete"] = null;
		_tween.vars["onUpdate"] = null;
		_tween.kill();
	}

	public function onComplete(onComplete:Function):void {
		if (_tween) {
			_tween.vars["onComplete"] = onComplete;
			_tween.vars["onCompleteParams"] = [this];
		}
	}

	public function onUpdate(onUpdate:Function):void {
		if (_tween) {
			_tween.vars["onUpdate"] = onUpdate;
			_tween.vars["onUpdateParams"] = [this];
		}
	}

	public function scaleTime(value:Number):void {
		if (_tween) { _tween.timeScale = value; }
	}

	public function drawBulletPointOn(sprite:Sprite, color:uint = 0x0fafcd):void {
		sprite.graphics.beginFill(color);
		sprite.graphics.drawCircle(0,0,2);
		sprite.graphics.endFill();
	}
}
}