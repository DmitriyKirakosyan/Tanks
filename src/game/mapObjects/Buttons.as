package game.mapObjects {
	import flash.display.Sprite;

	public class Buttons extends Sprite {
		
		public var stopAddTankButton:Sprite;
		public var dragTankButton:Sprite;
		
		public function Buttons():void{
			buttonDragTank();
			buttonStopAddTank();
			this.buttonMode = true;
		}
		
		/* Internal functions */
		
		private function buttonStopAddTank():void{
			stopAddTankButton = new Sprite();
			stopAddTankButton.graphics.lineStyle(1, 0x00000F);
			stopAddTankButton.graphics.beginFill(0xFFF000);
			stopAddTankButton.graphics.drawRect(0, 0, 20, 20);
			stopAddTankButton.graphics.endFill();
			this.addChild(stopAddTankButton);
			
		}
		
		private function buttonDragTank():void{
			dragTankButton = new Sprite();
			dragTankButton.graphics.lineStyle(1, 0x00000F);
			dragTankButton.graphics.beginFill(0x00FF00);
			dragTankButton.graphics.drawRect(30, 0, 20, 20);
			dragTankButton.graphics.endFill();
			this.addChild(dragTankButton);
		}
	}
}
