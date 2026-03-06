package game.world;

import core.util.Util;
import game.data.Names;

enum abstract Gene(Int) to Int {
    var None = 0;
    var Forward = 1;
    var Back = 2;
    var TurnTo = 3;
    var TurnAway = 4;

    // Attack Types
    var Pierce = 5;
    var Punch = 6;
    var Spit = 7;

    var Kiss = 8;
    var Deflect = 9;
}

final mutItems = [Pierce, Punch, Spit];

typedef DId = Int;

class Dna {
    public static var curId:Int;

    // static vals
    public final id:DId;
    public final name:String;
    public var generation:Int;
    public var wins:Int = 0;

    // public var speed:Int; // how fast each step is
    public var hp:Int;
    public var rad:Int = 0;

    public var body:Int;
    public var eyes:Int;

    public var genes:Array<Gene>;

    public function new (?genes:Array<Gene>, ?generation:Int = 0, ?hp:Null<Int>) {
        id = curId++;
        name = makeName();

        // dex = World.rand.GetUpTo(64);
        // attack = World.rand.GetUpTo(64);
        // defense = World.rand.GetUpTo(64);

        this.genes = genes ?? generateGenes();
        this.hp = hp ?? 64 + Run.inst.rand.GetUpTo(64);
        // this.speed = speed ?? Run.inst.rand.GetUpTo(64);
        this.generation = generation;

        body = Run.inst.rand.GetUpTo(7);
        eyes = Run.inst.rand.GetUpTo(7);
    }
}

function generateGenes ():Array<Gene> {
    while (true) {
        final genes = makeRandomGenes();

        var attacks = 1;
        var forwards = 0;
        var turns = 0;
        for (g in genes) {
            if (g == Pierce || g == Punch || g == Spit) {
                attacks++;
            }

            if (g == TurnAway || g == TurnTo) {
                turns++;
            }

            if (g == Forward) {
                forwards++;
            }
        }

        if (attacks > 0 && forwards > 0 && turns > 0) {
            return genes;
        }

        trace('trying again');
    }
}

function makeRandomGenes ():Array<Gene> {
    final dna = [];

    for (_ in 0...24) {
        final rand = Run.inst.rand.GetFloat();
        if (rand < 0.003) {
            dna.push(Pierce);
        } else if (rand < 0.006) {
            dna.push(Punch);
        } else if (rand < 0.01) {
            dna.push(Spit);
        } else if (rand < 0.09) {
            dna.push(Forward);
        } else if (rand < 0.16) {
            dna.push(Back);
        } else if (rand < 0.22) {
            dna.push(TurnTo);
        } else if (rand < 0.27) {
            dna.push(TurnAway);
        } else {
            dna.push(None);
        }
    }

    return dna;
}

function combineDna (dad1:Dna, dad2:Dna, mutRate:Float, offspring:Int):Array<Dna> {
    if (dad1.genes.length != dad2.genes.length) throw 'Inequal DNA length!';
    if (dad1.id == dad2.id) throw 'Same!';

    final sons = [];
    for (_ in 0...offspring) {
        final genes = [];
        for (i in 0...dad1.genes.length) {
            final rand = Run.inst.rand.GetFloat();
            final mutRand = Run.inst.rand.GetFloat();
            final item = if (mutRand < 0.01 * mutRate) {
                Run.inst.randomItem(mutItems);
            } else if (rand < 0.5) {
                dad1.genes[i];
            } else {
                dad2.genes[i];
            }
            genes.push(item);
        }

        if (Run.inst.rand.GetFloat() < 0.01 * mutRate) {
            genes.push(genes.shift());
        }

        if (Run.inst.rand.GetFloat() < 0.01 * mutRate) {
            genes.push(genes.shift());
        }

        if (Run.inst.rand.GetFloat() < 0.01 * mutRate) {
            genes.push(genes.shift());
        }

        final hp = if (Run.inst.rand.GetFloat() < 0.01 * mutRate) {
            Math.round((dad1.hp + dad2.hp) / 2) - Run.inst.randomInt(15) + 5;
        } else {
            Math.round((dad1.hp + dad2.hp) / 2);
        }

        // final speed = if (Run.inst.rand.GetFloat() < 0.01 * mutRate) {
        //     Math.round((dad1.speed + dad2.speed) / 2) - Run.inst.randomInt(15) + 5;
        // } else {
        //     Math.round((dad1.speed + dad2.speed) / 2);
        // }

        sons.push(
            new Dna(genes,
                Std.int(Math.max(dad1.generation + 1, dad2.generation + 1)),
                Std.int(clamp(hp, 0, 128)),
                // Std.int(clamp(speed, 0, 128)),
            )
        );
    }

    return sons;
}

