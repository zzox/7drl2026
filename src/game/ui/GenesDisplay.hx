package game.ui;

import core.gameobjects.GameObject;
import core.system.Camera;
import game.world.Dna;
import kha.Assets;
import kha.graphics2.Graphics;

class GenesDisplay extends GameObject {
    static inline final Width = 8;

    public var genes:Array<Gene>;
    public var dIndex:Int = -1;

    public function new (x:Int, y:Int, genes:Array<Gene>) {
        this.x = x;
        this.y = y;
        this.genes = genes;
    }

    override function update (delta:Float) {}

    override function render (g2:Graphics, cam:Camera) {
        final image = Assets.images.ui;
        final sizeX = 8;
        final sizeY = 8;

        for (i in 0...genes.length) {
            final evenRow = Math.floor(i / Width) % 2 == 0;
            final col = i % Width;

            final xx = evenRow ? col : (Width - col + 1);
            final yy = Math.floor(i / Width);

            if (i == dIndex) {
                g2.drawSubImage(
                    image,
                    x + xx * sizeX - 4,
                    y + yy * sizeY - 4,
                    112, 192, 16, 16
                );
            }

            if (genes[i] == None) continue;

            g2.drawSubImage(
                image,
                x + xx * sizeX,
                y + yy * sizeY,
                genes[i] * sizeX, 0, sizeX, sizeY
            );
        }
    }
}
