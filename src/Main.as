package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import game.GameController;

import menu.TankPodium;

[SWF(width=600, height=600, frameRate=25)]
	public class Main extends Sprite {
		private var container:Sprite; 
		public var gameController:GameController;
		
		public function Main() {
			container = new Sprite(); 
			this.addChild(container);
			const paper:PaperView = new PaperView();
			container.addChild(paper);
			
			//gameController = new GameController(container);
			new TankPodium(container);
		}

	}
}