package core.gameobjects;

import core.system.Camera;
import kha.Image;
import kha.graphics2.Graphics;

class SImage extends GameObject {
    // public var flipX:Bool = false;
    // public var flipY:Bool = false;

    public var image:Image;

    public function new (x:Float = 0.0, y:Float = 0.0, image:Image) {
        this.x = x;
        this.y = y;
        this.image = image;
    }

    override function update (delta:Float) {}

    override function render (g2:Graphics, camera:Camera) {
        // TODO: move these to inlined pre and post render?
        g2.pushTranslation(-camera.scrollX * scrollFactorX, -camera.scrollY * scrollFactorY);
        g2.pushScale(camera.scale, camera.scale);
        g2.color = Math.floor(255 * alpha) * 0x1000000 | color;

        g2.drawImage(image, x, y);

        g2.popTransformation();
        g2.popTransformation();
    }
}
