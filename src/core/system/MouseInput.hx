package core.system;

import core.Types;

class MouseInput {
    public function new () {}

    var _pressed:Array<Int> = [];
    var _justPressed:Array<Int> = [];
    var _justReleased:Array<Int> = [];

    public var screenPos:IntVec2 = new IntVec2(-1, -1);
    public var position:IntVec2 = new IntVec2(-1, -1);

    public function pressMouse (button:Int, _x:Int, _y:Int) {
        _pressed.push(button);
        _justPressed.push(button);
    }

    public function releaseMouse (button:Int, _x:Int, _y:Int) {
        _pressed = _pressed.filter((p) -> p != button);
        _justReleased.push(button);
    }

    public function mouseMove (x:Int, y:Int, moveX:Int, moveY:Int) {
        position.set(x, y);
    }

    // public function setMousePos (x:Int, y:Int) {
    //     position.set(x, y);
    // }

    public function update (delta:Float) {
        _justPressed.resize(0);
        _justReleased.resize(0);
        // for (btn in _pressed) { btn.time += delta; };
    }

    public function pressed (button:Int):Bool {
        return _pressed.contains(button);
    }

    public function justPressed (button:Int):Bool {
        return _justPressed.contains(button);
    }

    public function justReleased (button:Int):Bool {
        return _justReleased.contains(button);
    }
}