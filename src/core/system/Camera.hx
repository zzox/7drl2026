package core.system;

import core.Const;
import core.gameobjects.GameObject;
import core.util.Util;

// NOTE: pixel-locked camera. scrollXDiff and scrollYDiff are properties to help
// deal with jitter issues
class Camera {
    public var bgColor:Int = 0xff000000;

    public var scrollX:Float = 0.0;
    public var scrollY:Float = 0.0;
    public var width:Int;
    public var height:Int;

    // for now just one var, x and y can be created if necessary
    public var scale:Float = 1.0;

    public var followX:Null<GameObject>;
    public var followY:Null<GameObject>;

    public var boundsMinX:Int = -Const.RBN;
    public var boundsMinY:Int = -Const.RBN;
    public var boundsMaxX:Int = Const.RBN;
    public var boundsMaxY:Int = Const.RBN;

    public var offsetX:Int = 0;
    public var offsetY:Int = 0;

    public var lerpX:Float = 1.0;
    public var lerpY:Float = 1.0;

    public function new (width:Int, height:Int) {
        this.width = width;
        this.height = height;
    }

    public function update (delta:Float) {
        if (followX != null) {
            scrollX = lerp(followX.getMiddleX() - width / 2, scrollX, lerpX);
            // TEMP: wont work with lerp
            scrollX = Math.floor(scrollX);
        }

        if (followY != null) {
            scrollY = lerp(followY.getMiddleY() - height / 2, scrollY, lerpY);
            // TEMP: wont work with lerp
            scrollY = Math.floor(scrollY);
        }

        scrollX = clamp(scrollX - offsetX, boundsMinX, boundsMaxX - width);
        scrollY = clamp(scrollY - offsetY, boundsMinY, boundsMaxY - height);
    }

    public function startFollow (sprite:GameObject, offsetX:Int = 0, offsetY:Int = 0, lerpX:Float = 1.0, lerpY:Float = 1.0) {
        followX = sprite;
        followY = sprite;

        this.offsetX = offsetX;
        this.offsetY = offsetY;

        this.lerpX = lerpX;
        this.lerpY = lerpY;
    }

    public function stopFollow () {
        followX = null;
        followY = null;
    }

    public function setBounds (minX:Int, minY:Int, maxX:Int, maxY:Int) {
        boundsMinX = minX;
        boundsMinY = minY;
        boundsMaxX = maxX;
        boundsMaxY = maxY;
    }
}
