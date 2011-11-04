package game.mapObjects {

import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;
import game.MapObject;
import game.tank.Tank;

public class MedKit extends MapObject {
		
		//[Embed(source="../../../imgs/med.jpg")] static public var MedKitImg:Class;
		
		private var medKitSprite:Sprite;
		
		public function MedKit(point:Point){
			this.x = point.x;
			this.y = point.y;
			medKitSprite = new Sprite();
			medKitSprite.graphics.beginFill(0xffffff);
			medKitSprite.graphics.drawCircle(0, 0, 20);
			medKitSprite.graphics.endFill();
			medKitSprite.graphics.beginFill(0xFF0000);
			medKitSprite.graphics.drawRect(-12, -4, 25, 8);
			medKitSprite.graphics.endFill();
			medKitSprite.graphics.beginFill(0xFF0000);
			medKitSprite.graphics.drawRect(-4, -12, 8, 25);
			medKitSprite.graphics.endFill();
			//medKitSprite.addChild(new MedKitImg());
			this.addChild(medKitSprite);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		/* API */

		public function removeMedKitInt():void{
			this.removeChild(medKitSprite);
		}
		/* Internal functions */

		private function onAddedToStage(event:Event):void {
			medKitSprite.scaleX = medKitSprite.scaleY = .1;
			new TweenMax(medKitSprite, .5, {scaleX : .7, scaleY : .7, ease : Back.easeOut });
		}
	}
}
