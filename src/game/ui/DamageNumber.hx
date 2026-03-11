package game.ui;

import core.gameobjects.GameObject;
import core.system.Camera;
import kha.Assets;
import kha.graphics2.Graphics;

class DamageNumber extends GameObject {
    public var number:Int = 0;
    public function new (x:Int, y:Int) {
        this.x = x;
        this.y = y;
        this.color = 0xffb4202a;
    }

    override function update (delta:Float) {}

    final numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    override function render (g2:Graphics, cam:Camera) {
        g2.color = color;
        final numString = (number + '').split('');
        for (i in 0...numString.length) {
            final num = numString[i];
            g2.drawSubImage(
                Assets.images.ui,
                x + i * 4 + ((4 - numString.length) * 2),
                y,
                numbers.indexOf(num) * 8, 8, 5, 8
            );
        }
        g2.color = White;
    }
}
