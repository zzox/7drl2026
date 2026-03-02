package game.world;

import game.data.Names;
import game.world.Grid;

enum ActorState {
    None; // ready for our task.
}

typedef ActorId = Int;

class Actor {
    public static var curId:Int;
    // static vals
    public final id:ActorId;
    public final name:String;

    public var dna:Dna;

    // dynamic vals
    public var x:Int;
    public var y:Int;
    public var facing:RotationDir = North;
    public var time:Int = 1;

    public function new (dna:Dna, pos:Int) {
        id = curId++;
        name = makeName();

        if (pos == 0) {
            x = 1;
            y = 6;
        } else {
            x = 6;
            y = 1;
        }

        this.dna = dna;
    }

    public inline function isAt (x:Int, y:Int):Bool {
        return this.x == x && this.y == y;
    }
}
