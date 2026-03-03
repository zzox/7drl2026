package game.world;

import game.data.Stats;
import game.world.Dna;
import kha.math.Random;

enum abstract CommandType(Int) {
    var TempCommand = 0;
}

typedef Command = {
    var type:CommandType;
    // TODO: turn optional props into union type
    var ?dId:DId;
}

function makeTempCommand (dId:DId):Command {
    return {
        type: TempCommand,
        dId: dId
    }
}

class World {
    public var seed:Int;
    public static var rand:Random;
    public static var placeRand:Random;
    public var stats:Stats = newEmptyStats();

    public var time:Int = 0;
    public var money:Int = 1000;

    public var room:Room;

    public var commands:Array<{ step:Int, command: Command }> = [];

    public function new (?startSeed:Int) {
        // final ttt = Timer.stamp();
        // final rand = new kha.math.Random(1000);
        // for (_ in 0...1_000_000) {
        //     final i = rand.GetFloat();
        // }
        // trace(Timer.stamp() - ttt);

        this.seed = startSeed ?? Math.floor(Math.random() * 123456);
        rand = new kha.math.Random(seed);
        placeRand = new kha.math.Random(1312);
        Dna.curId = 0;

        makeRoom(null, null);
    }

    public function makeRoom (dna1:Null<Dna>, dna2:Null<Dna>) {
        room = new Room(dna1 ?? new Dna(), dna2 ?? new Dna());
    }

    public function doCommand (command:Command):Bool {
        if (command.type == TempCommand) {}
        commands.push({ step: time, command: command });
        return true;
    }

    public static function randomInt (num:Int):Int {
        return rand.GetUpTo(num - 1);
    }

    public static function randomItem <T>(items:Array<T>):T {
        return items[randomInt(items.length)];
    }
}
