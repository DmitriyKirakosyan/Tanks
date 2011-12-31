/**
 * User: dima
 * Date: 26/12/11
 * Time: 2:21 PM
 */
package game {
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import game.matrix.MapMatrix;

import game.tank.Tank;
import game.tank.TankBotController;
import game.tank.TankVO;

import state.UserState;

public class EndGameWindow extends Sprite{
	public function EndGameWindow() {
		createWindow();
		this.x = MapMatrix.MATRIX_HEIGHT * GameController.CELL/2;
		this.y = MapMatrix.MATRIX_WIDTH * GameController.CELL/2;
	}

	private function createWindow():void {
		var bkg:Sprite = new Sprite();
		bkg.graphics.beginFill(0x696969, .7);
		bkg.graphics.drawRect(-100, -50, 200, 100);
		bkg.graphics.endFill();
		bkg.filters = [new BlurFilter()];
		this.addChildAt(bkg, 0);
		var tanksSprite:Sprite = new Sprite();
		createScoreTank(tanksSprite, TankBotController.BASE_BOT, UserState.instance.firstKilledNum, 0);
		if (UserState.instance.secondKilledNum > 0) {
			createScoreTank(tanksSprite, TankBotController.ADVANCE_BOT, UserState.instance.secondKilledNum, 80);
		}
		if (UserState.instance.thirdKilledNum > 0) {
			createScoreTank(tanksSprite, TankBotController.HARD_BOT, UserState.instance.thirdKilledNum, 160);
		}
		tanksSprite.y = -tanksSprite.height/2;
		tanksSprite.x = -tanksSprite.width/2;
		this.addChild(tanksSprite);
	}

	private function createScoreTank(tanksSprite:Sprite,  tankType:uint, scoreValue:int, x:Number):void {
		var tank:Tank;
		var textField:TextField;
		tank = Tank.createBotTank(new TankVO(), tankType);
		tank.originX =tank.width/2 + x;
		tank.originY = tank.height/2;
		textField = createScoreTF(scoreValue);
		textField.x = x + tank.width + 10;

		tanksSprite.addChild(tank);
		tanksSprite.addChild(textField);
	}

	private function createScoreTF(value:int):TextField {
		var result:TextField = new TextField();
		result.selectable = false;
		result.autoSize = TextFieldAutoSize.LEFT;
		result.text = String(value);
		result.y = 20;
		result.textColor = 0xffffff
		return result;
	}


}
}
