package tilemap {
	import flash.display.Sprite;
	import flash.geom.Point;

	public class TileMap extends Sprite {
		private var _tiles:Vector.<Vector.<Tile>>;
		private var _numColumns:int;
		private var _numRows:int;

		public function TileMap(numRows:int,  numColumns:int):void {
			super();
			_numColumns = numColumns;
			_numRows = numRows;
			createTiles();
		}

		public function pointInMap(point:Point):Boolean {
			if (!_tiles || _tiles.length == 0 || _tiles[0].length == 0) { return false; }
			const i:int = point.x / _tiles[0][0].width;
			const j:int = point.y / _tiles[0][0].height;
			trace("[TileMap] i : " + i + ", j : " + j);
			return !(i < 0 || i > _tiles.length || j < 0 || j > _tiles[0].length);
		}

		public function remove():void {
			removeTiles();
		}
		
		/* Tests functions */
		
		private function setTilePosition(tile:Tile, i:int, j:int):void {
			tile.x = i * tile.width;
			tile.y = j * tile.height;
		}

		private function createTiles():void {
			_tiles = new Vector.<Vector.<Tile>>();
			var tile:Tile;
			for (var i:int = 0; i < _numColumns; ++i) {
				_tiles[i] = new Vector.<Tile>();
				for (var j:int = 0; j < _numRows; ++j) {
					tile = new Tile();
					setTilePosition(tile, i, j);
					_tiles[i].push(tile);
					this.addChild(tile);
				}
			}
		}

		private function removeTiles():void {
			if (!_tiles) { return; }
			for (var i:int = 0; i < _numColumns; ++i) {
				for (var j:int = 0; j < _numRows; ++j) {
					this.removeChild(_tiles[i][j]);
				}
			}
			_tiles = null;
		}
		
	}
}
