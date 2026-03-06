package game.world;

import game.world.Dna;

class Nursery {
    public var parents:Array<Dna>;
    public var children:Array<Dna>;

    public function new (dna1:Dna, dna2:Dna) {
        final t1 = Lambda.fold(dna1.genes, (item:Gene, res:Int) -> res + item, 0);
        final t2 = Lambda.fold(dna2.genes, (item:Gene, res:Int) -> res + item, 0);
        parents = [dna1, dna2];
        children = combineDna(dna1, dna2, (dna1.rad + dna2.rad) / 100, (t1 + t2) % 4 + 1);
    }
}
