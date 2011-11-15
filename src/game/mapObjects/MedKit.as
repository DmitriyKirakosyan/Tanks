package game.mapObjects {

import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import game.mapObjects.MapObject;

public class MedKit extends MapObject {
		
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
			this.addChild(medKitSprite);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage); //TODO надо ли удалять слушатель потом?
		}

		/* API */

		public function removeMedKitInt():void{
			this.removeChild(medKitSprite);
		}
		/* Internal functions */

		private function onAddedToStage(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			medKitSprite.scaleX = medKitSprite.scaleY = .1;
			new TweenMax(medKitSprite, .5, {scaleX : .7, scaleY : .7, ease : Back.easeOut });
		}
	}
}
