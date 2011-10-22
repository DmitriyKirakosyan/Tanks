package game.mapObjects {
import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import game.MapObject;
import game.tank.Tank;

public class MedKit extends MapObject {
		
		//[Embed(source="../../../imgs/med.jpg")] static public var MedKitImg:Class;
		
		private var medKitSprite:Sprite;
		
		public function MedKit(rect:Rectangle){
			this.x = rect.x;
			this.y = rect.y;
			medKitSprite = new Sprite();
		//	medKitSprite.addChild(new MedKitImg());
			this.addChild(medKitSprite);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		/* API */

		public function removeMedKit():void{
			this.removeChild(medKitSprite);
		}
		/* Internal functions */

		private function onAddedToStage(event:Event):void {
			medKitSprite.scaleX = medKitSprite.scaleY = .1;
			new TweenMax(medKitSprite, .5, {scaleX : .7, scaleY : .7, ease : Back.easeOut });
		}
	}
}
