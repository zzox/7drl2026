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

class World {
    public var seed:Int;
    public static var rand:Random;
    public static var placeRand:Random;
    public var stats:Stats = newEmptyStats();

    public var room:Room;

    public var commands:Array<{ step:Int, command: Command }> = [];

    // DEBUG:
    public var pool:Array<Dna> = [];
    public var winners:Array<Dna> = [];
    public var dnaIndex:Int;
    public var generation:Int = 0;
    public var stepdads:Int = 0;
    public var matches:Int = -1;

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

        // makeMany();
        // makeRoom(dnas[0], dnas[1]);
        // dnaIndex = 1;

        final adam = new Dna();
        final steve = new Dna();

        pool = combineDna(adam, steve, 20, 8);
        makeRoom(pool.shift(), pool.shift());
    }

    public function makeRoom (dna1:Dna, dna2:Dna) {
        room = new Room(dna1, dna2);
        matches++;
    }

    // DEBUG: narrowing down 10000
    // function getNextDna ():Dna {
    //     dnaIndex = (dnaIndex + 1) % dnas.length;
    //     return dnas[dnaIndex];
    // }
    // public function nextRoom () {
    //     var losers = [];
    //     if (room.checkDead() == 0) {
    //         losers = [room.actors[0].dna.id, room.actors[1].dna.id];
    //     } else if (room.actors[0].hp <= 0) {
    //         losers = [room.actors[0].dna.id];
    //     } else if (room.actors[1].hp <= 0) {
    //         losers = [room.actors[1].dna.id];
    //     }

    //     dnas = dnas.filter(d -> !losers.contains(d.id));

    //     makeRoom(getNextDna(), getNextDna());
    // }
    // public function makeMany () {
    //     for (_ in 0...10000) {
    //         dnas.push(new Dna());
    //     }
    // }

    function makeChildren () {
        var children = [];

        final mutRate = generation > 10 ? 1 : 20 - generation;
        final offspring = Math.round(Math.max(16 - generation / 2, 4));

        while (winners.length < 2) {
            stepdads++;
            winners.push(new Dna());
        }

        shuffle(winners, rand);

        while (winners.length > 0) {
            final dad1 = winners.shift();
            final dad2 = winners.shift();
            if (dad2 == null) {
                children.push(dad1);
                break;
            }
            children = children.concat(combineDna(dad1, dad2, mutRate, offspring));
        }
        pool = children;
        generation++;
    }

    public function nextRoom () {
        // var losers = [];
        if (room.checkDead() == 0) {
        } else if (room.actors[0].hp <= 0) {
            winners.push(room.actors[1].dna);
        } else if (room.actors[1].hp <= 0) {
            winners.push(room.actors[0].dna);
        }

        if (pool.length < 2) {
            if (winners.length < 100) {
                makeChildren();
            } else {
                shuffle(winners, rand);
                pool = winners;
            }
        }

        makeRoom(pool.shift(), pool.shift());
    }
    // public function makeMany () {
    //     for (_ in 0...10000) {
    //         dnas.push(new Dna());
    //     }
    // }

    public function doCommand (command:Command):Bool {
        if (command.type == TempCommand) {}
        commands.push({ step: 0, command: command });
        return true;
    }

    public static function randomInt (num:Int):Int {
        return rand.GetUpTo(num - 1);
    }

    public static function randomItem <T>(items:Array<T>):T {
        return items[randomInt(items.length)];
    }
}
