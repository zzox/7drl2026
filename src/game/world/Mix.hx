package game.world;

import core.util.Util;
import game.world.Dna;

class Mix {
    public var guy:Dna;
    public var prev:Array<Gene>;
    public var value:Array<Gene>;

    public function new (guy:Dna) {
        this.guy = guy;
        prev = guy.genes.copy();
        value = guy.genes.copy();
        shuffle(value, Run.inst.rand);
    }
}
