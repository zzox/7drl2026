package core.system;

import kha.input.KeyCode;

class KeysInput {
    public function new () {}

    var _pressed:Array<KeyCode> = [];
    var _justPressed:Array<KeyCode> = [];
    var _justReleased:Array<KeyCode> = [];

    public function pressButton (code:KeyCode) {
        if (_pressed.contains(code)) {
            return;
        }

        _pressed.push(code);
        _justPressed.push(code);
    }

    public function releaseButton (code:KeyCode) {
        _pressed = _pressed.filter((p) -> p != code);
        _justReleased.push(code);
    }

    public function update (delta:Float) {
        _justPressed.resize(0);
        _justReleased.resize(0);
        // for (btn in _pressed) { btn.time += delta; };
    }

    public function pressed (code:KeyCode):Bool {
        return _pressed.contains(code);
    }

    public function anyPressed (codes:Array<KeyCode>): Bool {
        for (i in 0..._pressed.length) {
            if (codes.contains(_pressed[i])) return true;
        }
        return false;
    }

    public function justPressed (code:KeyCode):Bool {
        return _justPressed.contains(code);
    }

    public function anyJustPressed (codes:Array<KeyCode>):Bool {
        for (i in 0..._justPressed.length) {
            if (codes.contains(_justPressed[i])) return true;
        }
        return false;
    }

    public function justReleased (code:KeyCode):Bool {
        return _justReleased.contains(code);
    }

    public function anyJustReleased (codes:Array<KeyCode>):Bool {
        for (i in 0..._justReleased.length) {
            if (codes.contains(_justReleased[i])) return true;
        }
        return false;
    }
}
