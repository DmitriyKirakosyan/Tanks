/**
 * User: dima
 * Date: 26/12/11
 * Time: 2:09 PM
 */
package menu {
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import game.GameController;

import game.matrix.MapMatrix;

public class TutorialWindow extends Sprite{
	public function TutorialWindow() {
		super();
		createImage();
	}

	private function createImage():void {
		var leftView:Sprite = new Tutorial2();
		var rightView:Sprite = new Tutorial1();
		leftView.x = -leftView.width/4+10;
		leftView.y = -leftView.height/4+10;
		rightView.x = rightView.width/4;
		rightView.y = rightView.height/4 +10;
		leftView.filters = [new GlowFilter(0)];
		rightView.filters = [new GlowFilter(0)];
		//leftView.alpha = .85;
		//rightView.alpha = .75;
		this.addChild(rightView);
		this.addChild(leftView);
		this.x = this.width/2;
		this.y = this.height/2;
		var leftText:TextField = new TextField();
		var rightText:TextField = new TextField();
		leftText.selectable = rightText.selectable = false;
		leftText.autoSize = rightText.autoSize = TextFieldAutoSize.LEFT
		leftText.x = -100//leftView.width/2 + 5;
		leftText.y = 60//-leftView.height/2 + 10;
		var textFormat:TextFormat = new TextFormat(null, 22, 0x191970);
		rightText.defaultTextFormat = textFormat;
		textFormat.italic = true;
		leftText.defaultTextFormat = textFormat;
		rightText.defaultTextFormat = textFormat;
		leftText.text = "click for attack";
		rightText.text = "drag for move";
		rightText.x = -70;
		rightText.y = 130;
		leftView.addChild(leftText);
		rightView.addChild(rightText);

		var bkg:Shape = new Shape();
		bkg.graphics.beginFill(0xBEBEBE, .8);
		var width:Number = MapMatrix.MATRIX_WIDTH*GameController.CELL;
		var height:Number = MapMatrix.MATRIX_WIDTH*GameController.CELL;
		bkg.graphics.drawRect(-width/2, -height/2, width, height);
		bkg.graphics.endFill();
		bkg.filters = [new BlurFilter()];
		bkg.x = 5;
		bkg.y = 29;
		this.addChildAt(bkg, 0);
	}
}
}
