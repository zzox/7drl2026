package game.world;

import core.util.Util;
import game.world.Dna;

class World {
    public var pool:Array<Dna> = [];
    public var dnaIndex:Int;
    public var generation:Int = 0;
    public var stepdads:Int = 0;
    public var matches:Int = -1;

    public var geneCopies:Array<Array<Dna>> = [];

    public function new () {

        // makeMany();
        // makeRoom(dnas[0], dnas[1]);
        // dnaIndex = 1;

        final adam = new Dna();
        final steve = new Dna();

        pool = combineDna(adam, steve, 1, 100);
        cull();

        for (_ in 0...Run.Generations) {
            gen();
            cull();
        }
    }

    public function cull () {
        while (pool.length < (generation + 4) * 4) {
            pool.push(new Dna());
            stepdads++;
        }

        while (pool.length >= (generation + 1) * 4) {
            simulateBattleAndAdd(pool.shift(), pool.shift());
        }
        makeCopies();
    }

    public function gen () {
        generation++;
        var nextGen = [];
        shuffle(pool, Run.inst.rand);
        while (pool.length < generation * 4) {
            if (pool.length > 1) {
                final items = combineDna(pool.shift(), pool.shift(), generation * 2, 8);
                final f = items.filter(i -> !i.coward);
                nextGen = nextGen.concat(f);
            } else {
                break;
            }
        }
        pool = nextGen;
    }

    function simulateBattleAndAdd (dna1:Dna, dna2:Dna) {
        final room = new Room(dna1, dna2);

        while (room.checkDead() == 0 && !room.checkSkip()) {
            room.step(0);
        }

        if (room.checkDead() == 0) {
        } else if (room.actors[0].hp <= 0) {
            pool.push(room.actors[1].dna);
        } else if (room.actors[1].hp <= 0) {
            pool.push(room.actors[0].dna);
        }

        matches++;
    }

    // function makeChildren () {
    //     var children = [];

    //     final mutRate = Math.max(5 - generation / 4, 1.0);
    //     final offspring = Math.round(Math.max(16 - generation / 2, 4));

    //     final w = winners.length;

    //     while (winners.length < 2) {
    //         stepdads++;
    //         winners.push(new Dna());
    //     }

    //     shuffle(winners, Run.inst.rand);

    //     while (winners.length > 0) {
    //         final dad1 = winners.shift();
    //         final dad2 = winners.shift();
    //         if (dad2 == null) {
    //             children.push(dad1);
    //             break;
    //         }
    //         children = children.concat(combineDna(dad1, dad2, mutRate, offspring));
    //     }
    //     pool = children;
    //     generation++;

    //     trace('genned', w, children.length);
    // }

    // public function nextRoom ():Bool {
    //     // var losers = [];


    //     if (pool.length < 2) {
    //         if (generation < 10 && winners.length < 666) {
    //             makeChildren();
    //             makeRandomCopy();
    //         } else if (winners.length > 2) {
    //             shuffle(winners, Run.inst.rand);
    //             pool = winners;
    //             makeRandomCopy();
    //         } else {
    //             return false;
    //         }
    //     }

    //     // makeRoom(pool.shift(), pool.shift());
    //     return true;
    // }

    function makeCopies () {
        geneCopies.push(pool.copy());
    }
}
