package tilemap {
import flash.display.Sprite;

import game.GameController;

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