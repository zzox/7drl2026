package game.world;

enum Gene {
    None;
    Forward;
    Back;
    TurnTo;
    TurnAway;

    // Attack Types
    Pierce;
    Punch;
    Spit;

    Deflect;
}

class Dna {
    public var speed:Int; // how fast each step is
    public var health:Int;
    public var attack:Int;
    public var defense:Int;
    public var dex:Int; // recovery from attack?

    public var genes:Array<Gene> = [];

    public function new () {
        speed = World.randomInt(64);
        health = World.randomInt(64);
        attack = World.randomInt(64);
        defense = World.randomInt(64);
        dex = World.randomInt(64);
    }
}
