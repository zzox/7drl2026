package core.gameobjects;

import core.system.Camera;
import kha.Image;
import kha.graphics2.Graphics;

// uses nine slice data to create image from a selection of an image.
// cannot scale or flip.
class NineSlice extends GameObject {
    public var tileIndex:Int = 0;
    public var topLeftX:Int;
    public var topLeftY:Int;
    public var bottomRightX:Int;
    public var bottomRightY:Int;
    // size of the element, not the underlying image
    public var elementSizeX:Int;
    public var elementSizeY:Int;

    public var image:Image;

    public function new (x:Float, y:Float, sizeX:Int, sizeY:Int, topLeftX:Int, topLeftY:Int, bottomRightX:Int, bottomRightY:Int, elementSizeX:Int, elementSizeY:Int, image:Image) {
        this.x = x;
        this.y = y;
        this.sizeX = sizeX;
        this.sizeY = sizeY;
        this.topLeftX = topLeftX;
        this.topLeftY = topLeftY;
        this.bottomRightX = bottomRightX;
        this.bottomRightY = bottomRightY;
        this.elementSizeX = elementSizeX;
        this.elementSizeY = elementSizeY;
        this.image = image;
    }

    override function update (delta:Float) {}

    override function render (g2:Graphics, camera:Camera) {
        // TODO: move these to inlined pre and post render?
        g2.pushTranslation(-camera.scrollX * scrollFactorX, -camera.scrollY * scrollFactorY);
        g2.pushScale(camera.scale, camera.scale);
        g2.color = Math.floor(255 * alpha) * 0x1000000 | color;

        final cols = Std.int(image.width / sizeX);

        // Upper-left quadrant
        g2.drawSubImage(
            image,
            x,
            y,
            (tileIndex % cols) * sizeX,
            Math.floor(tileIndex / cols) * sizeY,
            topLeftX,
            topLeftY
        );

        // Upper-middle quadrant
        g2.drawScaledSubImage(
            image,
            (tileIndex % cols) * sizeX + topLeftX,
            Math.floor(tileIndex / cols) * sizeY,
            bottomRightX - topLeftX,
            topLeftY,
            x + topLeftX,
            y,
            elementSizeX - topLeftX - (sizeX - bottomRightX),
            topLeftY
        );

        // Upper-right quadrant
        g2.drawSubImage(
            image,
            x + (elementSizeX - (sizeX - bottomRightX)),
            y,
            (tileIndex % cols) * sizeX + bottomRightX,
            Math.floor(tileIndex / cols) * sizeY,
            sizeX - bottomRightX,
            topLeftY
        );

        // Middle-left quadrant
        g2.drawScaledSubImage(
            image,
            (tileIndex % cols) * sizeX,
            Math.floor(tileIndex / cols) * sizeY + topLeftY,
            topLeftX,
            bottomRightY - topLeftY,
            x,
            y + topLeftY,
            topLeftX,
            elementSizeY - topLeftY - (sizeY - bottomRightY)
        );

        // Middle-middle quadrant
        g2.drawScaledSubImage(
            image,
            (tileIndex % cols) * sizeX + topLeftX,
            Math.floor(tileIndex / cols) * sizeY + topLeftY,
            bottomRightX - topLeftX,
            bottomRightY - topLeftY,
            x + topLeftX,
            y + topLeftY,
            elementSizeX - topLeftX - (sizeX - bottomRightX),
            elementSizeY - topLeftY - (sizeY - bottomRightY)
        );

        // Middle-right quadrant
        g2.drawScaledSubImage(
            image,
            (tileIndex % cols) * sizeX + bottomRightX,
            Math.floor(tileIndex / cols) * sizeY + topLeftY,
            sizeX - bottomRightX,
            bottomRightY - topLeftY,
            x + elementSizeX - (sizeX - bottomRightX),
            y + topLeftY,
            sizeX - bottomRightX,
            elementSizeY - topLeftY - (sizeY - bottomRightY)
        );

        // Bottom-left quadrant
        g2.drawSubImage(
            image,
            x,
            y + (elementSizeY - (sizeY - bottomRightY)),
            (tileIndex % cols) * sizeX,
            Math.floor(tileIndex / cols) * sizeY + bottomRightY,
            topLeftX,
            sizeY - bottomRightY
        );

        // Bottom-middle quadrant
        g2.drawScaledSubImage(
            image,
            (tileIndex % cols) * sizeX + topLeftX,
            Math.floor(tileIndex / cols) * sizeY + bottomRightY,
            bottomRightX - topLeftX,
            sizeY - bottomRightY,
            x + topLeftX,
            y + (elementSizeY - (sizeY - bottomRightY)),
            elementSizeX - topLeftX - (sizeX - bottomRightX),
            sizeY - bottomRightY
        );

        // Bottom-right quadrant
        g2.drawSubImage(
            image,
            x + (elementSizeX - (sizeX - bottomRightX)),
            y + (elementSizeY - (sizeY - bottomRightY)),
            (tileIndex % cols) * sizeX + bottomRightX,
            Math.floor(tileIndex / cols) * sizeY + bottomRightY,
            sizeX - bottomRightX,
            sizeY - bottomRightY
        );

        g2.popTransformation();
        g2.popTransformation();
    }
}
