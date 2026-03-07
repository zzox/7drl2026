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
    // public var stats:Stats = newEmptyStats();

    public var world:World;
    public var room:Null<Room>;
    public var nursery:Nursery;

    public var day:Int = 0;
    public var money:Int = 100;

    public var commands:Array<{ day:Int, command: Command }> = [];

    public var roster:Array<Dna> = [];
    public var order:Array<Dna> = [];

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
        final adam = new Dna();
        final steve = new Dna();

        roster = combineDna(adam, steve, 5, 4);

        world = new World();
    }

    public function makeRoom (dna1:Dna, dna2:Dna) {
        room = new Room(dna1, dna2);
        // matches++;
    }

    public function handleRoom () {
        if (!room.checkSkip() && room.checkDead() == 0) {
            throw 'No result on room?';
        }

        if (room.actors[0].hp <= 0) {
            roster = roster.filter(r -> r != room.actors[0].dna);
        } else {
            room.actors[0].dna.wins++;
        }

        room = null;
    }

    public function makeNursery (dna1:Dna, dna2:Dna) {
        nursery = new Nursery(dna1, dna2);
    }

    public function handleNursery () {
        roster = roster.filter(r -> !nursery.parents.contains(r));
        roster = roster.concat(nursery.children);
        nursery = null;
    }

    public function establishRun () {
        order = world.geneCopies.copy();
        world = null;
    }

    public function doCommand (command:Command):Bool {
        if (command.type == TempCommand) {}
        commands.push({ day: day, command: command });
        return true;
    }

    public function randomInt (num:Int):Int {
        return rand.GetUpTo(num - 1);
    }

    public function randomItem <T>(items:Array<T>):T {
        return items[randomInt(items.length)];
    }
}
