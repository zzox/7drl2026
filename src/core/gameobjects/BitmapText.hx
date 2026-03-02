package core.gameobjects;

import core.system.Camera;
import core.util.BitmapFont;
import kha.Image;
import kha.graphics2.Graphics;

class BitmapText extends GameObject {
    var image:Image;
    var font:BitmapFont;
    public var textWidth:Int = 0;
    var text:String;

    public function new (x:Int = 0, y:Int = 0, image:Image, font:BitmapFont, text:String = '') {
        this.x = x;
        this.y = y;
        this.image = image;
        this.font = font;
        setText(text);
    }

    override function update (delta:Float) {}

    override function render (g2:Graphics, camera:Camera) {
        g2.pushTranslation(-camera.scrollX * scrollFactorX, -camera.scrollY * scrollFactorY);
        g2.pushScale(camera.scale, camera.scale);

        g2.color = Math.floor(255 * alpha) * 0x1000000 | color;

        final lineHeight = font.getFontData().lineHeight;
        var scrollPos:Int = 0;
        var xPos:Int = Math.floor(x);
        var yPos:Int = Math.floor(y);
        final chars = text.split('');
        for (i in 0...chars.length) {
            final charData = font.getCharData(chars[i]);

            // most font types should be exact, construct 3's can wrap.
            final destX = charData.destX % image.realWidth;
            final destY = charData.destY + charData.destHeight *
                Math.floor(charData.destX / image.realWidth);

            g2.drawSubImage(
                image,
                xPos + scrollPos,
                yPos + lineHeight + charData.yOffset,
                destX,
                destY,
                charData.destWidth,
                charData.destHeight
            );

            scrollPos += charData.width;
        }
        textWidth = scrollPos;

        g2.popTransformation();
        g2.popTransformation();
    }

    public function setText (text:String) {
        this.text = text;
        textWidth = font.getTextWidth(text);
    }
}
