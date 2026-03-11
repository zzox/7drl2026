package core.gameobjects;

import kha.Image;

class AnimSprite extends Sprite {
    var frame:Int = -1;
    var frameTime:Int;
    var frames:Array<Int>;
    var repeats:Bool;

    public function new (x:Float, y:Float, image:Image, sizeX:Int, sizeY:Int, frameTime:Int, frames:Array<Int>, repeats:Bool = true) {
        super(x, y, image, sizeX, sizeY);

        this.frameTime = frameTime;
        this.frames = frames;
        this.repeats = repeats;
    }

    override function update (delta:Float) {
        final f = repeats ? ++frame % (frames.length * frameTime) : Math.min(++frame, frames.length * frameTime - 1);
        tileIndex = frames[Math.floor(f / frameTime)];
    }
}
