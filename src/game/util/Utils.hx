package game.util;

import core.Types.IntVec2;
import core.util.Util;
import game.world.Grid.RotationDir;

inline function checkEq (x1:Int, y1:Int, x2:Int, y2:Int) {
    return x1 == x2 && y1 == y2;
}

function getClosest (x:Int, y:Int, items:Array<IntVec2>):Null<IntVec2> {
    var closest:Null<IntVec2> = null;
    var closestDist:Float = Math.POSITIVE_INFINITY;

    for (i in items) {
        final dist = distanceBetween(x, y, i.x, i.y);
        if (dist < closestDist) {
            closest = i;
            closestDist = dist;
        }
    }

    return closest;
}

final lights = [0x5e606e, 0x848795, 0xb5b5b5, 0xd3d3d3, 0xe9e9e9, 0xffffff];
function getLightColor (light:Float) {
    return lights[Math.floor(light * 5)];
}

final distanceDiffs = [
    Macro.createDiffs(2),
    Macro.createDiffs(3),
    Macro.createDiffs(4),
    Macro.createDiffs(5),
    Macro.createDiffs(6),
    Macro.createDiffs(7),
    Macro.createDiffs(8),
    Macro.createDiffs(9),
    Macro.createDiffs(10),
    Macro.createDiffs(11),
    Macro.createDiffs(12),
    Macro.createDiffs(13),
    Macro.createDiffs(14),
    Macro.createDiffs(15),
    Macro.createDiffs(16),
];

function getDistanceDiffs (distance:Int):Array<IntVec2> {
    if (distance < 2 || distance > 16) {
        throw 'Bad distance';
    }

    return distanceDiffs[distance - 2];
}

function getRotDir (dir:RotationDir):Float {
    return switch (dir) {
        case East: toRadians(90);
        case South: toRadians(180);
        case West: toRadians(270);
        case North: toRadians(0);
    }
}
