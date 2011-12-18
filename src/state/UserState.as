package state {
import game.tank.TankVO;

public class UserState {
	private static var _instance:UserState;

	private var _tankVO:TankVO;

	private var _firstKilledNum:int;
	private var _secondKilledNum:int;
	private var _thirdKilledNum:int;

	public static function get instance():UserState {
		if (!_instance) { _instance = new UserState(); }
		return _instance;
	}

	public function UserState() {
		super();
		clean();
	}

	public function clean():void {
		_tankVO = new TankVO();
		_firstKilledNum = 0;
		_secondKilledNum = 0;
		_thirdKilledNum = 0;
	}

	public function get tankVO():TankVO { return _tankVO; }
	public function set tankVO(value:TankVO):void {
		_tankVO = value;
	}

	public function incFirstKilledNum():void { _firstKilledNum++; }
	public function incSecondKilledNum():void { _secondKilledNum++; }
	public function incThirdKilledNum():void { _thirdKilledNum++; }

	public function get firstKilledNum():int { return _firstKilledNum; }
	public function get secondKilledNum():int { return _secondKilledNum; }
	public function get thirdKilledNum():int { return _thirdKilledNum; }

}
}
