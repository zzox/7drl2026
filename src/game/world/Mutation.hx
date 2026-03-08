package game.world;

import core.util.Util;
import game.world.Dna;

class Mutation {
    public var guy:Dna;
    public var prev:Array<Gene>;
    public var value:Array<Gene>;

    public function new (guy:Dna) {
        prev = guy.genes.copy();
        value = guy.genes.copy();
        value[Run.inst.randomInt(guy.genes.length)] = Run.inst.randomItem(mutItems);
        this.guy = guy;
    }
}
