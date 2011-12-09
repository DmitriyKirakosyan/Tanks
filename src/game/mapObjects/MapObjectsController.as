package game.mapObjects {
import com.greensock.TweenMax;
import com.greensock.easing.Bounce;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

import game.IControllerWithTime;
import game.events.DamageObjectEvent;
import game.events.GameBonusEvent;
import game.events.TankShotingEvent;
import game.mapObjects.bonus.BonusManager;
import game.mapObjects.bonus.GameBonus;
import game.matrix.MapMatrix;
import game.matrix.MatrixItemIds;
import game.tank.TargetsController;
import game.tank.weapon.Bullet;
import game.tank.Tank;
import game.time.GameTimeZone;

import tilemap.TileMap;

public class MapObjectsController extends EventDispatcher implements IControllerWithTime{
	private var _mapMatrix:MapMatrix;
	private var _tileMap:TileMap;
	private var _container:Sprite;
	private var _stones:Vector.<Stone>;
	private var _bricks:Vector.<Brick>;
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

	public function dropBonus(bonusType:uint):void { _bonusManager.dropBonus(bonusType); }

	public function removeMapObjects():void {
		removeBricks();
		removeStones();
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

	public function scaleTime(value:Number):void {
		_scaleTime = value;
		if (_bullets) {
			for each (var bullet:Bullet in _bullets) {
				bullet.scaleTime(value);
			}
		}
		_targetsController.scaleTime(value);
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

	/* Internal functions */

	private function onEnterFrame(event:Event):void {
		checkObjectsInteract();
	}

	private function onEnemyTankShot(event:TankShotingEvent):void {
		addBullet(event.bullet);
	}

	/* сдесь будут отслеживаться основные столкновения */
	public function checkObjectsInteract():void {
		checkHitBonus();
	}

	private function addTimeZone(timeZone:GameTimeZone):void {
		if (!_timeZoneList) { _timeZoneList = new Vector.<GameTimeZone>(); }
		if (timeZone && _timeZoneList.indexOf(timeZone) == -1) {
			_timeZoneList.push(timeZone);
		}
	}

	private function onBonusAdded(event:GameBonusEvent):void {
		var point:Point = _mapMatrix.getRandomPoint();
		event.bonus.x = point.x;
		event.bonus.y = point.y;
		_container.addChild(event.bonus);
	}
		
	private function drawObjects():void {
		if (!_mapMatrix || !_mapMatrix.matrix) { return; }
		for (var i:int = 0; i < MapMatrix.MATRIX_WIDTH; ++i) {
			for (var j:int = 0; j < MapMatrix.MATRIX_HEIGHT; ++j) {
				if (_mapMatrix.matrix[i][j] == MatrixItemIds.STONE) {
					addStone(new Point(i, j));
				} else if (_mapMatrix.matrix[i][j] == MatrixItemIds.BRICKS) {
					addBrick(new Point(i, j));
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

	private function removeBullets():void {
		for each (var bullet:Bullet in _bullets) {
			bullet.remove();
			if (_container.contains(bullet)) { _container.removeChild(bullet);
			} else { trace("bullet not on container [MapObjectsController.removeBullets]"); }
		}
	}

	private function removeBonuses():void {
		for each (var gameBonus:GameBonus in _bonusManager.activeBonuseList) {
			if (_container.contains(gameBonus)) { _container.removeChild(gameBonus);
			} else { trace("WARN! bonus not on container [MapObjectsController.removeBonuses]"); }
		}
		_bonusManager.clear();
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
			if (enemyTank != bullet.selfTank &&
				bullet.hitTestObject(enemyTank)) {
				removeBullet(bullet);
				showBamOnTank(new Point(enemyTank.originX, enemyTank.originY));  //TODO all ok?
				removeEnemyTank(enemyTank);
				break;
			}
		}
	}

	private function checkHitStone(bullet:Bullet):void {
		if (!_stones) { return; }
		for each (var stone:Stone in _stones) {
			if (bullet.hitTestObject(stone)) {
				removeBullet(bullet);
				break;
			}
		}
	}
	private function checkHitBrick(bullet:Bullet):void {
		if (!_bricks) { return; }
		for each (var brick:Brick in _bricks) {
			if (bullet.hitTestObject(brick)) {
				removeBullet(bullet);
				if (brick.damaged) { removeBrick(brick);
				} else { brick.damage(); }
				break;
			}
		}
	}
	private function checkHitPlayerTank(bullet:Bullet):void {
		if (_playerTankKilled || !_playerTank) { return; }

		if (_playerTank != bullet.selfTank && bullet.hitTestObject(_playerTank)) {
			removeBullet(bullet);
			if (!_playerTank.hasDefence()) {
				dispatchEvent(new DamageObjectEvent(DamageObjectEvent.DAMAGE_PLAYER_TANK, _playerTank));
				showBamOnTank(new Point(_playerTank.originX, _playerTank.originY));
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

	private function showBamOnTank(point:Point, player:Boolean = false):void {
		const bam:BamView = new BamView();
		bam.x = point.x - bam.width/2;
		bam.y = point.y - bam.height/2;
		bam.scaleX = 0; bam.scaleY = 0;
		bam.alpha = .4;
		_container.addChild(bam);
		TweenMax.to(bam, .9, {scaleX : 1, scaleY : 1, alpha : 1, ease : Bounce.easeOut,
								onComplete: function():void {if (!player) {_container.removeChild(bam); }}});
	}

	private function onBulletComplete(bullet:Bullet):void {
		removeBullet(bullet);
	}
	private function removeBullet(bullet:Bullet):void {
		if (_container.contains(bullet)) { _container.removeChild(bullet); }
		bullet.remove();
		const index:int = _bullets.indexOf(bullet);
		if (index >= 0) { _bullets.splice(index, 1); }
	}

	private function removeBrick(brick:Brick):void {
		removeElementFromMap(brick);
		const index:int = _bricks.indexOf(brick);
		if (index >= 0) { _bricks.splice(index, 1); }
	}

	private function removeElementFromMap(element:MapObject):void {
		if (_container.contains(element)) { _container.removeChild(element); }
		_mapMatrix.clearCell(element.x,  element.y);
	}

	/* enemy tanks functions */
	private function removeEnemyTank(tank:Tank):void {
		_targetsController.killEnemyTank(tank);
	}
		
}
}
