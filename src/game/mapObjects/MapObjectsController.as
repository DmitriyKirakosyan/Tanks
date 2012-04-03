package game.mapObjects {
import game.mapObjects.MapNativeObject;
import game.tank.weapon.TankGun;
import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Bounce;
import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

import game.ControllerWithTime;
import game.events.DamageObjectEvent;
import game.events.GameBonusEvent;
import game.events.TankShotingEvent;
import game.mapObjects.bonus.BonusManager;
import game.mapObjects.bonus.GameBonus;
import game.matrix.MapMatrix;
import game.matrix.MatrixItemIds;
import game.tank.TankBotController;
import game.tank.TargetsController;
import game.tank.weapon.Bullet;
import game.tank.Tank;
import game.time.GameTimeZone;

import sound.Sounds;

import sound.SoundsManager;

import spark.effects.animation.Timeline;

import state.UserState;

import tilemap.TileMap;

public class MapObjectsController extends ControllerWithTime{
	private var _mapMatrix:MapMatrix;
	private var _tileMap:TileMap;
	private var _container:Sprite;
	private var _stones:Vector.<Stone>;
	private var _bricks:Vector.<Brick>;
	private var _puddles:Vector.<MapNativeObject>;
	private var _bullets:Vector.<Bullet>;
	private var _timeZoneList:Vector.<GameTimeZone>;
	private var _playerTank:Tank;
	private var _targetsController:TargetsController;

	private var _playerTankKilled:Boolean = false;

	private var _scaleTime:Number;

	private var _bonusManager:BonusManager;

	public function MapObjectsController(matrix:MapMatrix, container:Sprite):void {
		super();
		_scaleTime = 1;
		_mapMatrix = matrix;
		_container = container;
		_bonusManager = new BonusManager();
		_bonusManager.addEventListener(GameBonusEvent.BONUS_ADDED, onBonusAdded);
		_targetsController = new TargetsController(_container, _mapMatrix);
	}
	
	/*API*/

	public function get targetsController():TargetsController { return _targetsController; }
	public function get bricks():Vector.<Brick> { return _bricks; }
	public function get stones():Vector.<Stone> { return _stones; }
	
	public function dropBonus(bonusType:uint):void { _bonusManager.dropBonus(bonusType); }

	public function removeMapObjects():void {
		removeBricks();
		removeStones();
		removePuddles();
	}

	public function init():void {
		_mapMatrix.createMatrix();
		_tileMap = new TileMap(MapMatrix.MATRIX_WIDTH, MapMatrix.MATRIX_HEIGHT);
		_container.addChildAt(_tileMap, 0);
		drawObjects();
		_targetsController.init();
		_targetsController.addEventListener(TankShotingEvent.WAS_SHOT, onEnemyTankShot);
		_container.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	public function remove():void {
		_container.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		_container.removeChild(_tileMap);
		_tileMap.remove();
		removeBricks();
		removeStones();
		removeBullets();
		removeBonuses();
		_playerTankKilled = false;
		_scaleTime = 1;
		_targetsController.remove();
		_targetsController.removeEventListener(TankShotingEvent.WAS_SHOT, onEnemyTankShot);
	}

	/* time functions */

	override protected function scaleTime(value:Number):void {
		_scaleTime = value;
		if (_bullets) {
			for each (var bullet:Bullet in _bullets) {
				bullet.scaleTime(value);
			}
		}
		//_targetsController.scaleTime(value);
	}

	public function pause():void {
		if (_bullets) {
			for each (var bullet:Bullet in _bullets) {
				bullet.pause();
			}
		}
		_targetsController.pause();
	}
	public function resume():void {
		if (_bullets) {
			for each (var bullet:Bullet in _bullets) {
				bullet.resume();
			}
		}
		_targetsController.resume();
	}

	public function putBrick(brick:Brick):void {
		var point:Point = new Point(int(brick.x + .5),  int(brick.y + .5));
		if (_mapMatrix.isFreeCell(point.x, point.y)) {
			addBrick(point);
		}
	}
	public function putStone(stone:Stone):void {
		var point:Point = new Point(int(stone.x + .5),  int(stone.y + .5));
		if (_mapMatrix.isFreeCell(point.x,  point.y)) {
			addStone(point);
		}
	}

	public function addBullet(bullet:Bullet):void {
		if (!_bullets) { _bullets = new Vector.<Bullet>(); }
		_bullets.push(bullet);
		bullet.scaleTime(_scaleTime);
		bullet.onComplete(onBulletComplete);
		bullet.onUpdate(onBulletUpdate);
		bullet.setContainer(_container);
	}

	public function addPlayerTank(tank:Tank):void {
		if (_playerTank) { trace("WARN!! player tank already exists [MapObjectsController.addPlayerTank]"); }
		_playerTank = tank;
		_targetsController.addPlayerTank(tank);
	}

	public function resetObjects():void {
		removeMapObjects();
		drawObjects();
	}

	/* сдесь будут отслеживаться основные столкновения */
	public function checkObjectsInteract():void {
		checkHitBonus();
	}

	/* Internal functions */

	private function onEnterFrame(event:Event):void {
		checkObjectsInteract();
	}

	private function onEnemyTankShot(event:TankShotingEvent):void {
		addBullet(event.bullet);
	}

	private function onBonusAdded(event:GameBonusEvent):void {
		var point:Point = _mapMatrix.getRandomPoint();
		if (event.tank) {
			point = new Point(event.tank.x,  event.tank.y);
		}
		addBonus(event.bonus, point);
	}
	
	private function addBonus(gameBonus:GameBonus, point:Point):void {
		gameBonus.x = point.x;
		gameBonus.y = point.y;
		_container.addChild(gameBonus);
	}

	private function drawObjects():void {
		if (!_mapMatrix || !_mapMatrix.matrix) { return; }
		for (var i:int = 0; i < MapMatrix.MATRIX_WIDTH; ++i) {
			for (var j:int = 0; j < MapMatrix.MATRIX_HEIGHT; ++j) {
				if (_mapMatrix.matrix[i][j] == MatrixItemIds.STONE) {
					addStone(new Point(i, j));
				} else if (_mapMatrix.matrix[i][j] == MatrixItemIds.BRICKS) {
					addBrick(new Point(i, j));
				} else if (_mapMatrix.matrix[i][j] == MatrixItemIds.PUDDLE) {
					addPuddle(new Point(i, j));
				}
			}
		}
	}

	private function addStone(mPoint:Point):void {
		var stone:Stone;
		stone = new Stone(mPoint);
		if (!_stones) { _stones = new Vector.<Stone>(); }
		_stones.push(stone);
		_container.addChild(stone);
		_mapMatrix.setCell(mPoint.x, mPoint.y, MatrixItemIds.STONE);
	}
	private function removeStones():void {
		for each (var stone:Stone in _stones) {
			 removeElementFromMap(stone);
			_stones= new Vector.<Stone>();
		}
	}

	private function addBrick(mPoint:Point):void {
		var brick:Brick;
		brick = new Brick(mPoint);
		if (!_bricks) { _bricks = new Vector.<Brick>(); }
		_bricks.push(brick);
		_container.addChild(brick);
		_mapMatrix.setCell(mPoint.x, mPoint.y, MatrixItemIds.BRICKS);
	}
	private function removeBricks():void {
		for each (var brick:Brick in _bricks) {
			removeElementFromMap(brick);
			_bricks = new Vector.<Brick>();
		}
	}

	private function addPuddle(mPoint:Point):void {
		var puddle:MapNativeObject;
		puddle = new MapNativeObject(mPoint, new Puddle());
		if (!_puddles) { _puddles = new Vector.<MapNativeObject>(); }
		_puddles.push(puddle);
		_container.addChild(puddle);
		_mapMatrix.setCell(mPoint.x, mPoint.y, MatrixItemIds.PUDDLE);
	}
	private function removePuddles():void {
		for each (var puddle:MapNativeObject in _puddles) {
			removeElementFromMap(puddle);
			_puddles = new Vector.<MapNativeObject>();
		}
	}

	private function removeBonuses():void {
		for each (var gameBonus:GameBonus in _bonusManager.activeBonuseList) {
			if (_container.contains(gameBonus)) { _container.removeChild(gameBonus);
			} else { trace("WARN! bonus not on container [MapObjectsController.removeBonuses]"); }
		}
		_bonusManager.clear();
	}

	/* bullet functions */
	private function onBulletUpdate(bullet:Bullet):void {
		bullet.updateEffect();
		checkHitEnemyTank(bullet);
		checkHitStone(bullet);
		checkHitBrick(bullet);
		checkHitPlayerTank(bullet);
	}

	private function checkHitEnemyTank(bullet:Bullet):void {
		for each (var enemyTank:Tank in _targetsController.getEnemyTanks()) {
			if (enemyTank != bullet.selfTank && enemyTank.hitTestObject(bullet)) {
				removeBullet(bullet);
				enemyTank.damage(bullet.damageStrength);
				if (enemyTank.destroyed) {
					if (bullet.selfTank == _playerTank) {
						addScore(enemyTank);
					}
					removeEnemyTank(enemyTank);
					addBonus(_bonusManager.addGaussGunBonus(), new Point(enemyTank.x, enemyTank.y));
				}
				break;
			}
		}
	}

	private function checkHitStone(bullet:Bullet):void {
		if (!_stones) { return; }
		for each (var stone:Stone in _stones) {
			if (bullet.hitTestObject(stone)) {
				removeBullet(bullet,false);
				stone.damage(bullet.damageStrength);
				if (stone.destroyed) { removeStone(stone); }
				break;
			}
		}
	}
	private function checkHitBrick(bullet:Bullet):void {
		if (!_bricks) { return; }
		for each (var brick:Brick in _bricks) {
			if (bullet.hitTestObject(brick)) {
				removeBullet(bullet,false);
				brick.damage(bullet.damageStrength);
				if (brick.destroyed) { removeBrick(brick); }
				break;
			}
		}
	}
	private function checkHitPlayerTank(bullet:Bullet):void {
		if (_playerTankKilled || !_playerTank) { return; }

		if (_playerTank != bullet.selfTank && _playerTank.hitTestObject(bullet)) {
			removeBullet(bullet);
			if (!_playerTank.hasDefence()) {
				dispatchEvent(new DamageObjectEvent(DamageObjectEvent.DAMAGE_PLAYER_TANK, _playerTank, bullet.damageStrength));
			}
		}
	}

	private function checkHitBonus():void {
		var gameBonus:GameBonus = _bonusManager.getBonusUnder(_playerTank);
		if (gameBonus) {
			if (_container.contains(gameBonus)) {
				_container.removeChild(gameBonus);
			} else { trace("warning!! game bonus dont contains on container [MapObjectsController.checkHitBonus]"); }
			_bonusManager.removeBonus(gameBonus);
			dispatchEvent(GameBonusEvent.createBonusApplyToPlayerEvent(gameBonus));
		}
	}

	private function onBulletComplete(bullet:Bullet):void {
		removeBullet(bullet, false);
	}
	private function removeBullet(bullet:Bullet, goal:Boolean = true):void {
		if (_container.contains(bullet)) { _container.removeChild(bullet); }
		bullet.remove();
		const index:int = _bullets.indexOf(bullet);
		if (index >= 0) { _bullets.splice(index, 1); }
		bulletBamEffect(bullet.x,  bullet.y);
		SoundsManager.playSoundByName(goal ? Sounds.SHOT_GOAL_2 : Sounds.SHOT_GOAL_1);
	}

	private function removeBullets():void {
		for each (var bullet:Bullet in _bullets) {
			bullet.remove();
			if (_container.contains(bullet)) { _container.removeChild(bullet);
			} else { trace("bullet not on container [MapObjectsController.removeBullets]"); }
		}
	}

	private function bulletBamEffect(x:Number,  y:Number):void {
		var bamSprite:BulletBam = new BulletBam();
		bamSprite.x = x;
		bamSprite.y = y;
		bamSprite.rotation = _playerTank.gun.rotation;
		bamSprite.scaleX = bamSprite.scaleY = .05;
		_container.addChild(bamSprite);
		TweenLite.to(bamSprite, .4, {scaleX : .3, scaleY : .3, ease : Linear.easeNone,
																onComplete : function():void {_container.removeChild(bamSprite); }});
	}

	private function removeBrick(brick:Brick):void {
		removeElementFromMap(brick);
		const index:int = _bricks.indexOf(brick);
		if (index >= 0) { _bricks.splice(index, 1); }
	}

	private function removeStone(stone:Stone):void {
		removeElementFromMap(stone);
		const index:int = _stones.indexOf(stone);
		if (index >= 0) { _stones.splice(index, 1); }
	}

	private function removeElementFromMap(element:MapObject):void {
		if (_container.contains(element)) { _container.removeChild(element); }
		_mapMatrix.clearCell(element.x,  element.y);
	}

	/* enemy tanks functions */
	private function removeEnemyTank(tank:Tank):void {
		_targetsController.killEnemyTank(tank);
	}

	private function addScore(enemyTank:Tank):void {
		switch (_targetsController.strengthOf(enemyTank)) {
			case TankBotController.ADVANCE_BOT :
				UserState.instance.incSecondKilledNum();
				break;
			case TankBotController.HARD_BOT :
				UserState.instance.incThirdKilledNum();
				break;
			default  :
				UserState.instance.incFirstKilledNum();
		}
	}

}
}
