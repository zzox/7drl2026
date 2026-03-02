package core.scene;

import core.gameobjects.GameObject;
import core.gameobjects.Sprite;
import core.system.Camera;
import core.system.Timers;
import kha.Image;
import kha.graphics2.Graphics;

class Scene /* implements Destroyable */ {
    public var destroyed:Bool = false;

    public var entities:Array<GameObject> = [];

    public var camera:Camera;

    public var game:Game;

    public var timers:Timers;

    public function new () {
        timers = new Timers();
    }

    public function create () {}

    public function update (delta:Float) {
        timers.update(delta);

        for (e in entities) {
            if (e.active) e.update(delta);
        }

        camera.update(delta);
    }

    // called when drawing, passes in graphics instance
    // overriding render will require you to call begin, clear and end
    // public function render (graphics:Graphics, g4:kha.graphics4.Graphics, clears:Bool) {
    public function render (graphics:Graphics, clears:Bool) {
        graphics.begin(clears, camera.bgColor);

        for (e in entities) {
            if (e.visible) e.render(graphics, camera);
        }

// #if debug_physics
//         for (sprite in entities) {
//             sprite.renderDebug(graphics, camera);
//         }
// #end
        graphics.end();
    }

    public inline function makeSprite (x:Float = 0.0, y:Float = 0.0, image:Image, ?sizeX:Int, ?sizeY:Int):Sprite {
        final sprite = new Sprite(x, y, image, sizeX, sizeY);
        entities.push(sprite);
        return sprite;
    }

    public function destroy () {
        destroyed = true;
        timers.destroy();
    }
}
