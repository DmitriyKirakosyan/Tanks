package tilemap {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;

import game.GameController;

import game.mapObjects.Stone;

public class Tile extends Sprite {

		public function Tile() {
			super();
			init();
		}
		
		private function init():void{
			addChild(new GroundM());
			this.width = GameController.CELL;
			this.height = GameController.CELL;
		}
		
	}
}