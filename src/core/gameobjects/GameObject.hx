package core.gameobjects;

import core.system.Camera;
import kha.graphics2.Graphics;

class GameObject {
    public var destroyed:Bool = false;

    public var active:Bool = true;
    public var visible:Bool = true;

    public var x:Float;
    public var y:Float;
    public var sizeX:Int;
    public var sizeY:Int;
    public var scrollFactorX:Float = 1.0;
    public var scrollFactorY:Float = 1.0;

    public var color:Int = 0xffffff;
    public var alpha:Float = 1.0;

    public function start () {
        active = true;
        visible = true;
    }

    public function stop () {
        active = false;
        visible = false;
    }

    public function update (delta:Float) {
        throw 'GameObject::update not implemented';
    }

    public function render (g2:Graphics, camera:Camera) {
        throw 'GameObject::render not implemented';
    }

    public function getMiddleX () return x + sizeX / 2;
    public function getMiddleY () return y + sizeY / 2;

    public function setPosition (x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    public function setScrollFactor (x:Float, y:Float) {
        this.scrollFactorX = x;
        this.scrollFactorY = y;
    }
}
