/**
 * Created by : Dmitry
 * Date: 11/1/11
 * Time: 11:49 PM
 */
package game.tank {
public class TankDestroyMethodFactory {
	private static var _numMethods:uint;

	public function TankDestroyMethodFactory() {
		super();
		_numMethods = 2;
	}

	public static function createMethodById(methodId:uint, tank:Tank):TankDestroyMethod {
		var result:TankDestroyMethod;
		switch (methodId) {
			case 0 : result = new TankDestoryRotation(tank);

			default : result = new TankDestroyFlash(tank);
		}
		return result;
	}

	public static function createRandomMethod(tank):TankDestroyMethod {
		return createMethodById(Math.random()*_numMethods, tank);
	}
}
}
