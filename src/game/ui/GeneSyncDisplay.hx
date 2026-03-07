package game.ui;

import core.gameobjects.GameObject;
import core.system.Camera;
import game.world.Dna;
import kha.Assets;
import kha.graphics2.Graphics;

final FirstBounce = 0.5;
final IncTime = 0.05;

function getTweenData (time:Float, bounces:Int, baseY:Float, down:Bool):Float {
    if (down) {
        if (time < 0.0) {
            return baseY;
        } else if (time < FirstBounce) {
            return baseY + time * 6.0;
        } else if (time < FirstBounce + bounces * 1.0 - 0.5) {
            return baseY - Math.sin(6 * ((time - FirstBounce) % 1.0)) * 6;
        }
    } else {
        if (time < 0.0) {
            return baseY;
        } else if (time < FirstBounce) {
            return baseY - time * 6.0;
        } else if (time < FirstBounce + bounces * 1.0 - 0.5) {
            return baseY + Math.sin(6 * ((time - FirstBounce) % 1.0)) * 6;
        }
    }
    
    return -16;
}

class GeneSyncDisplay extends GameObject {
    public var genes:Array<Gene>;
    public var geneTimes:Array<Float>;
    var down:Bool;
    var bounces:Int;

    public function new (x:Int, y:Int, genes:Array<Gene>, down:Bool, bounces:Int) {
        this.x = x;
        this.y = y;
        this.genes = genes;
        this.geneTimes = [for (i in 0...genes.length) i * -IncTime];
        this.down = down;
        this.bounces = bounces;
    }

    override function update (delta:Float) {
        geneTimes = geneTimes.map(gt -> gt += delta);
    }

    override function render (g2:Graphics, cam:Camera) {
        final image = Assets.images.ui;
        final sizeX = 8;
        final sizeY = 8;

        for (i in 0...genes.length) {
            final yy = getTweenData(geneTimes[i], bounces, y, down);  
            // final yy = 0;

            g2.drawSubImage(
                image,
                x + i * sizeX,
                yy,
                ((i % 2 == 0) ? 31 : 30) * sizeX, 0, sizeX, sizeY
            );

            if (genes[i] == None) continue;

            g2.drawSubImage(
                image,
                x + i * sizeX,
                yy,
                genes[i] * sizeX, 0, sizeX, sizeY
            );
        }
    }
}
