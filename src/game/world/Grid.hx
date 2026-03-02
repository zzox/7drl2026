package game.world;

typedef Grid<T> = {
    var width:Int;
    var height:Int;
    var items:Array<T>;
}

/**
 * Methods for making and handling grids.
 */
enum abstract RotationDir(Int) from Int to Int {
    var North = 0;
    var South = 1;
    var East = 2;
    var West = 3;
}

function makeGrid<T> (width:Int, height:Int, initialValue:T):Grid<T> {
    return {
        width: width,
        height: height,
        items: [for (i in 0...(width * height)) initialValue],
    }
}

function forEachGI<T> (grid:Grid<T>, callback:(x:Int, y:Int, item:T) -> Void) {
    for (x in 0...grid.width) {
        for (y in 0...grid.height) {
            callback(x, y, grid.items[x + y * grid.width]);
        }
    }
}

function mapGI<T, TT> (grid:Grid<T>, callback:(x:Int, y:Int, item:T) -> TT):Grid<TT> {
    // don't know about this as it requires a cast
    // if (callback == null) {
    //     callback = (x:Int, y:Int, item:T) -> { return cast(item); };
    // }

    final items = [];
    // ATTN: these are flipped so they are pushed to be accessed by grid.items[x + y * grid.width];
    for (y in 0...grid.height) {
        for (x in 0...grid.width) {
            items.push(callback(x, y, grid.items[x + y * grid.width]));
        }
    }

    return {
        width: grid.width,
        height: grid.height,
        items: items
    }
}

function getGridItem<T> (grid:Grid<T>, x:Int, y:Int):Null<T> {
    if (x < 0 || y < 0 || x >= grid.width || y >= grid.height) {
        return null;
    }

    return grid.items[x + y * grid.width];
}

function setGridItem<T> (grid:Grid<T>, x:Int, y:Int, item:T) {
    grid.items[x + y * grid.width] = item;
}

// function getDirFromDiff (diffX:Int, diffY:Int):RotationDir {
//     if (diffX == 1 && diffY == 0) return East;
//     if (diffX == 0 && diffY == -1) return North;
//     if (diffX == 0 && diffY == 1) return South;
//     if (diffX == -1 && diffY == 0) return West;
//     throw 'Dir not found';
// }

function figureRotationMath (num:Int):RotationDir {
    var n = num % 4;
    while (n < 0) {
        n += 4;
    }
    return n;
}

function calculateFacing (actorFacing:Int, worldRotation:Int):RotationDir {
    return figureRotationMath(actorFacing + worldRotation);
}

function gridFromItems <T>(width:Int, height:Int, items:Array<T>):Grid<T> {
    return {
        width: width,
        height: height,
        items: items
    }
}

function copyGrid <T>(grid:Grid<T>):Grid<T> {
    return {
        width: grid.width,
        height: grid.height,
        items: grid.items.copy()
    }
}
