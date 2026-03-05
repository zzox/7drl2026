package game.world;

import core.util.Util;
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

class Run {
    public static var inst:R;

    public function new () {
        inst = new R();
        inst.init();
    }
}
class R {
    public var seed:Int;
    public var rand:Random;
    public var placeRand:Random;
    public var stats:Stats = newEmptyStats();

    public var room:Room;

    public var commands:Array<{ step:Int, command: Command }> = [];

    public var pool:Array<Dna> = [];

    public var geneCopies:Array<Dna> = [];

    public function new (?startSeed:Int) {
        // final ttt = Timer.stamp();
        // final rand = new kha.math.Random(1000);
        // for (_ in 0...1_000_000) {
        //     final i = rand.GetFloat();
        // }
        // trace(Timer.stamp() - ttt);

        this.seed = startSeed ?? Math.floor(Math.random() * 1234567);
        rand = new kha.math.Random(seed);
        placeRand = new kha.math.Random(1312);
        Dna.curId = 0;
    }

    public function init () {

        // makeMany();
        // makeRoom(dnas[0], dnas[1]);
        // dnaIndex = 1;

        final adam = new Dna();
        final steve = new Dna();

        pool = combineDna(adam, steve, 20, 8);
    }

    public function makeRoom (dna1:Dna, dna2:Dna) {
        room = new Room(dna1, dna2);
        // matches++;
    }

    public function doCommand (command:Command):Bool {
        if (command.type == TempCommand) {}
        commands.push({ step: 0, command: command });
        return true;
    }

    public function randomInt (num:Int):Int {
        return rand.GetUpTo(num - 1);
    }

    public function randomItem <T>(items:Array<T>):T {
        return items[randomInt(items.length)];
    }
}
