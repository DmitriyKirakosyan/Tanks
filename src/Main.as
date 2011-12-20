package {
import flash.display.Sprite;

import game.GameController;
import game.SceneController;

[SWF(width=600, height=600, frameRate=25)]
	public class Main extends Sprite {
		private var container:Sprite;
		//mochimedia.com
		var _mochiads_game_id:String = "88119fe352061898";

		public function Main() {
			container = new Sprite(); 
			this.addChild(container);

			new SceneController(container);
		}

	}
}