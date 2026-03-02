package game.world;

import game.world.Grid;

class Actor {
    public var dna:Dna;

    // dynamic vals
    public var x:Int;
    public var y:Int;
    public var facing:RotationDir;
    public var time:Int = 60;
    public var hp:Int;
    public var dnaIndex:Int = 0;

    public function new (dna:Dna, pos:Int) {
        if (pos == 0) {
            x = 1;
            y = 6;
            facing = North;
        } else {
            x = 6;
            y = 1;
            facing = South;
        }

        this.dna = dna;
        hp = dna.hp;
    }

    public inline function isAt (x:Int, y:Int):Bool {
        return this.x == x && this.y == y;
    }
}
