package game.ui;

import core.Game;
import core.gameobjects.BitmapText;
import core.gameobjects.GameObject;
import core.scene.Scene;
import core.system.Camera;
import core.util.Util;
import game.ui.UiButtons;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Utils;
import game.world.Dna;
import game.world.Run;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;

typedef ChildElement = {
    var el:UiElement;
    // var el:GameObject;
    var x:Int;
    var y:Int;
}
typedef OChildElement = {
    // var el:UiElement;
    var el:GameObject;
    var x:Int;
    var y:Int;
}

class GeneSelectWindow {
    public var visible:Bool = true;
    public var x:Int;
    public var y:Int;
    public var name:String;

    public var width:Int = 0;
    public var height:Int = 0;

    public var children:Array<ChildElement> = [];
    var oChildren:Array<OChildElement> = [];

    public var selectedIndex:Int = -1;
    public var items:Array<{ button:UiElement, icon:GuyIcon }> = [];

    public var guy:GuyIcon;
    public var nameText:BitmapText;
    public var hpText:BitmapText;
    public var spText:BitmapText;
    public var rdText:BitmapText;

    public var genes:GenesDisplay;

    public var flashTime:Float = 0.0;

    public function new (x:Int, y:Int, name:String) {
        this.x = x;
        this.y = y;
        this.name = name;

        // bg + name
        addChild(0, 0, new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 280, 72, 21, Assets.images.ui));
        addChild(12, 12, new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 256, 32, 20, Assets.images.ui));
        addChild(4, -4, new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 64, 16, 28, Assets.images.ui));
        addUpChild(4, -6, makeBitmapText(0, 0, name, 0xdae0ea));

        makeIcons();

        guy = addUpChild(14, 14, new GuyIcon());
        hpText = addUpChild(32, 10, makeWhiteText(''));
        spText = addUpChild(32, 20, makeWhiteText(''));
        // rdText = addUpChild(20, 0, makeWhiteText(''));
        nameText = addUpChild(0, 16, makeWhiteText(''));

        genes = addUpChild(14, 35, new GenesDisplay(0, 0, [], 24));
    }

    function makeIcons () {
        for (i in 0...12) {
            // final row = Math.floor(i / 12);
            // final col = i % 12;

            final button = makeUiButton(0, 0, 20, 20, 24, () -> {
                select(i);
            });
            final icon = new GuyIcon();

            addChild(4 + 20 * i, 48, button);
            addUpChild(4 + 20 * i + 2, 48 + 2, icon);

            items.push({ button: button, icon: icon });
        }
    }

    function select (num:Int) {
        selectedIndex = num;

        final item = Run.inst.pool[num];
        guy.dna = item;
        hpText.setText('hp: ${item.hp}');
        spText.setText('sp: ${item.speed}');
        // rdText.setText('rd: ${67}');

        // gross!
        nameText.setText(item.name);
        final child = oChildren.filter(o -> o.el == nameText)[0];
        child.x = 256 - nameText.textWidth;

        genes.genes = item.genes;
    }

    public function deselect () {
        selectedIndex = -1;
    }

    public function update (delta:Float) {
        for (c in children) c.el.update(delta);
        for (c in oChildren) c.el.update(delta);
        for (i in 0...items.length) {
            if (selectedIndex == i) {
                items[i].button.hovered = true;
                items[i].icon.frames++;
            } else {
                items[i].icon.frames = 0;
            }
        }
        flashTime -= delta;
    }

    public function render (g2:Graphics, cam:Camera) {
        for (c in children) {
            c.el.x = x + c.x;
            c.el.y = y + c.y;
            if (c.el.visible) c.el.render(g2, cam);
        }
        for (o in oChildren) {
            o.el.x = x + o.x;
            o.el.y = y + o.y;
            if (o.el.visible) o.el.render(g2, cam);
        }
    }

    function addChild (x:Int, y:Int, el:UiElement) {
        children.push({ x: x, y: y, el: el });
        width = Std.int(Math.max(width, x + el.elementSizeX));
        height = Std.int(Math.max(height, y + el.elementSizeY));
    }

    function addUpChild<T:GameObject>(x:Int, y:Int, el:T):T {
        oChildren.push({ x: x, y: y, el: el });
        return el;
    }

    function addUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void):TextButton {
        final uiButton = makeUiTextButton(0, 0, width, height, tileIndex, text, callback);
        addChild(x, y, uiButton.button);
        addUpChild(Std.int(x + uiButton.text.x), Std.int(y + uiButton.text.y), uiButton.text);
        return uiButton;
    }
}

class GuyIcon extends GameObject {
    public var dna:Null<Dna>;
    public var frames:Int = 0;

    public function new () {}

    override function update (delta:Float) {}

    override function render (g2:Graphics, cam:Camera) {
        if (dna != null) {
            final sizeX = 16;
            final sizeY = 16;

            final image = Assets.images.ui;
            final cols = Std.int(image.width / sizeX);

            g2.pushRotation(
                toRadians(Math.floor(frames / 90) * 90),
                x + 8,
                y + 8
            );

            final tileIndex = 112 + dna.body;
            g2.drawSubImage(
                image,
                x,
                y,
                (tileIndex % cols) * sizeX, Math.floor(tileIndex / cols) * sizeY, sizeX, sizeY
            );

            final tileIndex = 128 + dna.eyes;
            g2.drawSubImage(
                image,
                x,
                y,
                (tileIndex % cols) * sizeX, Math.floor(tileIndex / cols) * sizeY, sizeX, sizeY
            );
            g2.popTransformation();
        }
    }
}
