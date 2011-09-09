package game.mapObjects {
	import flash.text.TextFormat;
	import flash.text.TextField;
	import com.greensock.TimelineMax;
	import flash.display.Shape;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import game.GameController;
	import flash.geom.Point;
	import flash.display.Sprite;

import game.MapObject;

public class Mine extends MapObject{
		private var _distance:int;
		private var _activated:Boolean;
		
		private var _tween:TweenMax;
		private var _numbersTimeline:TimelineMax;
		
		public function Mine(pint:Point):void {
			_distance = 3;
			_activated = false;
			this.x = pint.x;
			this.y = pint.y;
			super();
		}
		/*
		override public function set x(value:Number):void {
			super.x = value * GameController.CELL + GameController.CELL/2;
		}
		override public function set y(value:Number):void {
			super.y = value * GameController.CELL + GameController.CELL/2;
		}
		override public function get x():Number { return (super.x - GameController.CELL/2) / GameController.CELL;}
		override public function get y():Number { return (super.y - GameController.CELL/2) / GameController.CELL; }
		*/
		/* API */
		
		public function get distance():int { return _distance; }
		
		public function activate(_scaleTime:Number):void {
			if (_activated) { return; }
			_activated = true;
			this.graphics.beginFill(0xaa0f00);
			this.graphics.drawCircle(0, 0, 2);
			this.graphics.endFill();
			const mine:Sprite = this;
			const numbersText:TextField = new TextField();
			_tween = new TweenMax(
					this, .5, {alpha : 0, repeat : 5, yoyo: true, onComplete : 
					function():void { bam(); numbersText.visible = false;}, timeScale : _scaleTime});
					
			const textFormat:TextFormat = new TextFormat();
			textFormat.size = 20;
			textFormat.color = 0xaa0f00;
			numbersText.defaultTextFormat = textFormat;
			numbersText.text = "5";
			numbersText.x = -numbersText.textWidth*1.5;
			numbersText.y = -numbersText.textHeight*1.2;
			this.addChild(numbersText);
			_numbersTimeline = new TimelineMax({timeScale : _scaleTime});
			for (var i:int = 0; i < 5; ++i) {
				_numbersTimeline.append(new TweenMax(numbersText, .5, {
					scaleX : 2, scaleY : 2,
					onStart : function():void {
						numbersText.scaleX = 1;
						numbersText.scaleY = 1;
						numbersText.text = String(int(numbersText.text)-1);
					}
				}));
			}
		}
		
		public function scaleTime(value:Number):void {
			if (_tween) { _tween.timeScale = value; }
			if (_numbersTimeline) { _numbersTimeline.timeScale = value; }
		}
		
		/* Internal functions */
		private function bam():void {
			dispatchEvent(new Event(Event.CONNECT));
			trace("BAM");
			showBam();
		}
		
		private function showBam():void {
			const shape:Shape = new Shape();
			shape.graphics.beginFill(0x0fb0af);
			const maxSize:int = (_distance+1) * GameController.CELL;
			shape.graphics.drawCircle(0, 0, 1);
			shape.graphics.endFill();
			addChild(shape);
			TweenMax.to(shape, .6, {scaleX : maxSize, scaleY : maxSize, alpha : 0});
		}
	}
}
