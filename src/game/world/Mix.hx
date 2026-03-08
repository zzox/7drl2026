package game.world;

import core.util.Util;
import game.world.Dna;

class Mix {
    public var guy:Dna;
    public var prev:Array<Gene>;
    public var value:Array<Gene>;

    public function new (guy:Dna) {
        prev = guy.genes.copy();
        value = guy.genes.copy();
        shuffle(value, Run.inst.rand);
    }
}