package core.util;

import core.Types;

function clamp (value:Float, min:Float, max:Float) {
    return Math.max(Math.min(value, max), min);
}

function lerp (target:Float, current:Float, percent:Float):Float {
    return current + (target - current) * percent;
}

function toRadians (value:Float):Float {
    return value * (Math.PI / 180);
}

function toDegrees (value:Float):Float {
    return value / (Math.PI / 180);
}

// from: https://github.com/HaxeFlixel/flixel/blob/dev/flixel/math/FlxVelocity.hx
function velocityFromAngle (angle:Float, velocity:Float):Vec2 {
    final a = toRadians(angle);
    return new Vec2(Math.cos(a) * velocity, Math.sin(a) * velocity);
}

// from: https://stackoverflow.com/questions/2676719/calculating-the-angle-between-a-line-and-the-x-axis
function angleFromPoints (p1x:Float, p1y:Float, p2x:Float, p2y:Float):Float {
    return toDegrees(Math.atan2(p1y - p2y, p1x - p2x));
}

function distanceBetween (x1:Float, y1:Float, x2:Float, y2:Float) {
    return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}

// Returns true if two rectangles overlap.
function rectOverlap (
    r1px:Float,
    r1py:Float,
    r1sx:Float,
    r1sy:Float,
    r2px:Float,
    r2py:Float,
    r2sx:Float,
    r2sy:Float
):Bool {
    return r1px + r1sx >= r2px
        && r1px <= r2px + r2sx
        && r1py + r1sy >= r2py
        && r1py <= r2py + r2sy;
}

function pointInRect (px:Float, py:Float, rx:Float, ry:Float, rw:Float, rh:Float) {
    return px >= rx && py >= ry && px < rx + rw && py < ry + rh;
}

function average (arr:Array<Float>):Float {
    if (arr.length == 0) return 0;
    return Lambda.fold(arr, (item, res) -> {
        return item + res;
    }, 0) / arr.length;
}

function nanZero (num:Float):Float {
    if (Math.isNaN(num)) {
        return 0.0;
    }

    return num;
}

function nanZeroDiv (num:Float, denom:Float):Float {
    if (denom == 0) {
        return 0;
    }

    return num / denom;
}
