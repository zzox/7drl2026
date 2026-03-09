package game.world;

import core.util.Util;
import game.world.Dna;

class Mutation {
    public var guy:Dna;
    public var prev:Array<Gene>;
    public var index:Int;
    public var gene:Gene;
    public var value:Array<Gene>;

    public function new (guy:Dna) {
        prev = guy.genes.copy();
        value = guy.genes.copy();
        index = Run.inst.randomInt(guy.genes.length);
        gene = Run.inst.randomItem(mutItems);
        value[index] = gene;
        this.guy = guy;
    }
}
