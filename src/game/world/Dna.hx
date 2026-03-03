package game.world;

import game.data.Names;

enum Gene {
    None;// = 0;
    Forward;// = 1;
    Back;// = 2;
    TurnTo;// = 3;
    TurnAway;// = 4;

    // Attack Types
    Pierce;// = 5;
    Punch;// = 6;
    Spit;// = 7;

    Deflect;// = 8;
}

typedef DId = Int;

class Dna {
    public static var curId:Int;

    // static vals
    public final id:DId;
    public final name:String;

    public var speed:Int; // how fast each step is
    public var hp:Int;

    public var genes:Array<Gene>;

    public function new () {
        id = curId++;
        name = makeName();

        hp = 64 + World.rand.GetUpTo(64);
        speed = World.rand.GetUpTo(64);
        // dex = World.rand.GetUpTo(64);
        // attack = World.rand.GetUpTo(64);
        // defense = World.rand.GetUpTo(64);

        genes = generateGenes();
    }
}

function generateGenes ():Array<Gene> {
    while (true) {
        final genes = makeRandomGenes();

        var attacks = 0;
        var forwards = 0;
        var turns = 0;
        for (g in genes) {
            if (g == Pierce) {
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
        final rand = World.rand.GetFloat();
        if (rand < 0.06) {
            dna.push(Pierce);
        } else if (rand < 0.06) {
            dna.push(Punch);
        } else if (rand < 0.12) {
            dna.push(Forward);
        } else if (rand < 0.14) {
            dna.push(Back);
        } else if (rand < 0.18) {
            dna.push(TurnAway);
        } else if (rand < 0.25) {
            dna.push(TurnTo);
        } else {
            dna.push(None);
        }
    }

    return dna;
}
