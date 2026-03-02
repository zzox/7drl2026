package core.gameobjects;

import core.system.Camera;
import kha.Image;
import kha.graphics2.Graphics;

class Tilemap extends GameObject {
    var image:Image;

    public function new (x:Int, y:Int, tileImage:Image, width:Int, height:Int, tileWidth:Int, tileHeight:Int, tiles:Array<Null<Int>>) {
        image = Image.createRenderTarget(tileWidth * width, tileHeight * height);

        image.g2.begin();
        for (i in 0...tiles.length) {
            final tileNum = tiles[i] - 1;
            if (tileNum >= 0) {
                image.g2.drawSubImage(
                    tileImage,
                    (i % width) * tileWidth,
                    Math.floor(i / width) * tileHeight,
                    (tileNum % Math.floor(tileImage.width / tileWidth)) * tileHeight,
                    Math.floor(tileNum / Math.floor(tileImage.width / tileWidth)) * tileWidth,
                    tileWidth,
                    tileHeight
                );
            }
        }
        image.g2.end();

        this.x = x;
        this.y = y;
    }

    override function update (delta:Float) {}

    override function render (g2:Graphics, camera:Camera) {
        g2.pushTranslation(-camera.scrollX * scrollFactorX, -camera.scrollY * scrollFactorY);
        g2.pushScale(camera.scale, camera.scale);
        g2.drawImage(image, Math.floor(x), Math.floor(y));
        g2.popTransformation();
        g2.popTransformation();
    }
}
