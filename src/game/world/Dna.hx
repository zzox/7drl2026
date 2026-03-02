package game.world;

enum abstract Gene(Int) {
    var None = 0;
    var Forward = 1;
    var Back = 2;
    var TurnTo = 3;
    var TurnAway = 4;

    // Attack Types
    var Pierce = 5;
    var Punch = 6;
    var Spit = 7;

    var Deflect = 8;
}

class Dna {
    public var speed:Int; // how fast each step is
    public var hp:Int;

    public var genes:Array<Gene>;

    public function new () {
        hp = 64 + World.rand.GetUpTo(64);
        speed = World.rand.GetUpTo(64);
        // dex = World.rand.GetUpTo(64);
        // attack = World.rand.GetUpTo(64);
        // defense = World.rand.GetUpTo(64);

        genes = generateGenes();
    }
}

function generateGenes ():Array<Gene> {
    final dna = [];

    for (_ in 0...24) {
        final rand = World.rand.GetFloat();
        if (rand < 0.01) {
            dna.push(Pierce);
        } else if (rand < 0.02) {
            dna.push(Punch);
        } else if (World.rand.GetFloat() < 0.12) {
            dna.push(Forward);
        } else if (World.rand.GetFloat() < 0.22) {
            dna.push(Back);
        } else if (World.rand.GetFloat() < 0.26) {
            dna.push(TurnAway);
        } else if (World.rand.GetFloat() < 0.3) {
            dna.push(TurnTo);
        } else {
            dna.push(None);
        }
    }

    return dna;
}
