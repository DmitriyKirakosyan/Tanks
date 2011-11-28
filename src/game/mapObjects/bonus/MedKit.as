package game.mapObjects.bonus {

import flash.display.Sprite;

public class MedKit extends GameBonus {
		
		private var medKitSprite:Sprite;
		
		public function MedKit(){
			super(GameBonus.MEDKIT);
			medKitSprite = new Sprite();
			draw();
			this.addChild(medKitSprite);
		}

		/* API */

		public function removeMedKitInt():void{
			if (medKitSprite && this.contains(medKitSprite)) { this.removeChild(medKitSprite); }
		}

		/* Internal functions */

		private function draw():void {
			medKitSprite.graphics.beginFill(0xffffff);
			medKitSprite.graphics.drawCircle(0, 0, 20);
			medKitSprite.graphics.endFill();
			medKitSprite.graphics.beginFill(0xFF0000);
			medKitSprite.graphics.drawRect(-12, -4, 25, 8);
			medKitSprite.graphics.endFill();
			medKitSprite.graphics.beginFill(0xFF0000);
			medKitSprite.graphics.drawRect(-4, -12, 8, 25);
			medKitSprite.graphics.endFill();
		}

	}
}
