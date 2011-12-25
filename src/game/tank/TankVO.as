/**
 * Created by IntelliJ IDEA.
 * User: dima
 * Date: 9/9/11
 * Time: 10:34 AM
 * To change this template use File | Settings | File Templates.
 */
package game.tank {
import game.mapObjects.ObjectsHp;


public class TankVO {
	public var tankBase:uint;
	public var destroyMethod:uint;
	public var weaponType:uint;
	public var hp:int;
	public var speed:int;
	public var ability:uint;

	public static const DEFAULT_BASE:uint = 0;
	public static const BRICK_BASE:uint = 1;
	
	public static const ENEMY_BASE_1:uint = 2;
    public static const ENEMY_BASE_2:uint = 3;
    public static const ENEMY_BASE_3:uint = 4;

	public function TankVO():void {
		tankBase = DEFAULT_BASE;
		destroyMethod = 0;
		weaponType = 0;
		hp = ObjectsHp.PLAYER;
		speed = 5;
		ability = 0; //coming soon
	}

	public function getClone():TankVO {
		var res:TankVO = new TankVO();
		res.tankBase = this.tankBase;
		res.destroyMethod = this.destroyMethod;
		res.weaponType = this.weaponType;
		res.ability = this.ability;
		return res;
	}
}
}
