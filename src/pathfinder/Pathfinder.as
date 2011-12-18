package pathfinder {
import flash.geom.Point;

public class Pathfinder{
	private static var _matrix:Vector.<Vector.<uint>>;
	private static var w:int;
	private static var h:int;
	
	private static var _from:Point;
	private static var _to:Point;
	
	private static var bestPath:Vector.<Point>;
	private static var pathMatrix:Vector.<Vector.<Point>>;
	private static var bypassFunctionsQueue:Vector.<Function>;

	public static function setMatrix(value:Vector.<Vector.<uint>>):void{
		if (value.length == 0) { throw new Error("uncorrect matrix, 0 rows"); }
		if (value && value.length > 0 && value[0].length > 0){
			_matrix = value;
			w = value.length;
			h = value[0].length;
		}
	}
	
	public static function getPath(from:Point, to:Point):Vector.<Point>{
		bestPath = new Vector.<Point>();
		if (cantWalk(from, to)) { return bestPath; }
		init(from, to);
		waveAlg(_from, _from, _to, cloneMatrix());
		if (bestPath.length != 0) {
			bestPath.shift();
			bestPath.push(to);
		}
		//if (bestPath.length == 0) { waveAlg(_from, _from, _to, makeFreeMatrix()); }
		return  bestPath;
	}
	
	public static function getFreePath(from:Point, to:Point):Vector.<Point>{
		bestPath = new Vector.<Point>();
		if (cantWalk(from, to)) { return bestPath; }
		init(from, to);
		waveAlg(_from, _from, _to, makeFreeMatrix());
		bestPath.push(to);
		return bestPath;
	}
	
	private static function cantWalk(from:Point, to:Point):Boolean{
		if (!_matrix || !from || !to ||
				outOfMatrix(from) || outOfMatrix(to)){
			return true;
		}
		return false;
	}
	
	private static function init(from:Point, to:Point):void{
		bypassFunctionsQueue = new Vector.<Function>();
		setDefaultBypassFunctionsQueue();
		createPathMatrix(w, h);
		_from = new Point(int(from.x), int(from.y));
		_to = new Point(int(to.x), int(to.y));
	}
	
	private static function setDefaultBypassFunctionsQueue():void{
		bypassFunctionsQueue.push(leftPoint, topPoint, rightPoint, bottomPoint);
	}
	
	private static function createPathMatrix(w:int, h:int):void{
		pathMatrix = new Vector.<Vector.<Point>>(w);
		for (var i:int = 0; i < w; ++i){
			pathMatrix[i] = new Vector.<Point>(h);
		}
	}
	
	private static function waveAlg(lastPoint:Point, currentPoint:Point, endPoint:Point, 
																	matrix:Vector.<Vector.<uint>>):void{
		pathMatrix[currentPoint.x][currentPoint.y] = lastPoint;
		if (currentPoint.equals(endPoint)){
			updateBestPath(getPathFromPathMatrix(currentPoint));
		}else{
			setBypassFunctionsQueue(currentPoint, endPoint);
			matrix[currentPoint.x][currentPoint.y] = 1;
			for each (var bypassFunction:Function in bypassFunctionsQueue){
				if (canMoveToPoint(matrix, bypassFunction(currentPoint))) {
					waveAlg(currentPoint, bypassFunction(currentPoint), endPoint, matrix);
				}
			}
		}
	}
	
	private static function setBypassFunctionsQueue(currentPoint:Point, endPoint:Point):void{
		var changed:Boolean;
		do{
			changed = false;
			for (var i:int = 1; i < bypassFunctionsQueue.length; ++i){
				if (Point.distance(bypassFunctionsQueue[i](currentPoint), endPoint) < 
							Point.distance(bypassFunctionsQueue[i-1](currentPoint), endPoint)){
					swapElementsInQueue(bypassFunctionsQueue, i-1, i);
					if (!changed) {changed = true;}
				}
			}
		}while(changed);
	}
	
	private static function getPathFromPathMatrix(currentPoint:Point):Vector.<Point>{
		var currentPath:Vector.<Point> = new Vector.<Point>;
		recursionPathGetter(currentPoint, currentPath);
		return currentPath;
	}
	private static function recursionPathGetter(currPoint:Point, currPath:Vector.<Point>):Point{
		if (!pathMatrix[currPoint.x][currPoint.y].equals(currPoint)){
			currPath.push(recursionPathGetter(pathMatrix[currPoint.x][currPoint.y], currPath));
		}
		return currPoint;
	}
	
	private static function updateBestPath(path:Vector.<Point>):void{
		if ((bestPath.length == 0) || (path.length < bestPath.length)) bestPath = path;
	}
	
	private static function canMoveToPoint(matrix:Vector.<Vector.<uint>>, point:Point):Boolean{
		if (point.x < 0 || point.x > matrix.length-1){
			return false;
		}else if (point.y < 0 || point.y > matrix[0].length - 1){
			return false;
		}
		return (matrix[point.x][point.y] == 0);
	}
	
	private static function leftPoint(point:Point):Point{
		return new Point(point.x - 1, point.y);
	}
	private static function rightPoint(point:Point):Point{
		return new Point(point.x + 1, point.y);
	}
	private static function topPoint(point:Point):Point{
		return new Point(point.x, point.y - 1);
	}
	private static function bottomPoint(point:Point):Point{
		return new Point(point.x, point.y + 1);
	}
	
	private static function cloneMatrix():Vector.<Vector.<uint>>{
		var resultMatrix:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>;
		for (var i:int = 0; i < w; ++i){
			resultMatrix[i] = new Vector.<uint>;
			for (var j:int = 0; j < h; ++j){
				resultMatrix[i][j] = _matrix[i][j];
			}
		}
		return resultMatrix;
	}
	
	private static function makeFreeMatrix():Vector.<Vector.<uint>>{
		var resultMatrix:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		for (var i:int = 0; i < w; ++i){
			resultMatrix[i] = new Vector.<uint>;
			for (var j:int = 0; j < h; ++j){
				resultMatrix[i][j] = 0;
			}
		}
		return resultMatrix;
	}

	private static function swapElementsInQueue(queue:Vector.<Function>, index1:int, index2:int):void{
		var varForSwap:Function = queue[index1];
		queue[index1] = queue[index2];
		queue[index2] = varForSwap;
	}
	
	private static function outOfMatrix(point:Point):Boolean{
		if (point.x < 0 || point.x >= w ||
				point.y < 0 || point.y >= h) {
			return true;
		}
		return false;
	}

}
}
