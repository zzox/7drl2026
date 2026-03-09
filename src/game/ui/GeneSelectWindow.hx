package game.ui;

import core.Game;
import core.gameobjects.BitmapText;
import core.gameobjects.GameObject;
import core.gameobjects.Sprite;
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
    public var selected:Null<Dna>;
    var items:Array<{ button:UiElement, icon:GuyIcon }> = [];

    public var leftArrow:UiElement;
    public var rightArrow:UiElement;

    public var guy:GuyIcon;
    public var nameText:BitmapText;
    public var hpText:BitmapText;
    public var spText:BitmapText;
    public var rdText:BitmapText;
    public var winText:BitmapText;
    public var genText:BitmapText;

    var docile:Sprite;
    var coward:Sprite;

    public var page:Int = 0;

    public var genes:GenesDisplay;

    public var flashTime:Float = 0.0;

    var onSet:(num:Int) -> Void;

    public function new (x:Int, y:Int, name:String, onSet:(num:Int) -> Void) {
        this.x = x;
        this.y = y;
        this.name = name;

        // bg + name
        addChild(0, 0, new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 280, 64, 21, Assets.images.ui));
        addChild(4, -2, new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 56, 16, 28, Assets.images.ui));
        addChild(8, 8, new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 264, 30, 20, Assets.images.ui));
        addUpChild(4, -6, makeBitmapText(0, 0, name, 0xdae0ea));

        makeIcons();

        guy = addUpChild(10, 10, new GuyIcon());
        hpText = addUpChild(28, 6, makeWhiteText(''));
        rdText = addUpChild(28, 16, makeWhiteText(''));
        winText = addUpChild(80, 6, makeWhiteText(''));
        genText = addUpChild(80, 16, makeWhiteText(''));
        nameText = addUpChild(0, 10, makeWhiteText(''));

        docile = new Sprite(0, 0, Assets.images.ui, 32, 8);
        docile.tileIndex = 36;
        docile.visible = false;
        addUpChild(132, 10, docile);

        coward = new Sprite(0, 0, Assets.images.ui, 32, 8);
        coward.tileIndex = 37;
        coward.visible = false;
        addUpChild(132, 20, coward);

        genes = addUpChild(16, 28, new GenesDisplay(0, 0, [], 24));

        leftArrow = new UiElement(0, 0, 8, 8, 2, 2, 6, 6, 8, 8, 50, Assets.images.ui, () -> {
            page--;
            setIcons();
        });
        rightArrow = new UiElement(0, 0, 8, 8, 2, 2, 6, 6, 8, 8, 18, Assets.images.ui, () -> {
            page++;
            setIcons();
        });
        addChild(12, 46, leftArrow);
        addChild(260, 46, rightArrow);

        this.onSet = onSet;
        setIcons();
    }

    function makeIcons () {
        for (i in 0...12) {
            // final row = Math.floor(i / 12);
            // final col = i % 12;

            final button = makeUiButton(0, 0, 20, 20, 24, () -> {
                select(i);
            });
            final icon = new GuyIcon();

            addChild(20 + 20 * i, 40, button);
            addUpChild(20 + 20 * i + 2, 40 + 2, icon);

            items.push({ button: button, icon: icon });
        }
    }

    function setIcons () {
        final diff = page * 12;

        for (i in 0...12) {
            final ii = diff + i;
            if (Run.inst.roster[ii] != null) {
                items[i].button.disabled = false;
                items[i].icon.dna = Run.inst.roster[ii];
            } else {
                items[i].button.disabled = true;
                items[i].icon.dna = null;
            }
        }

        leftArrow.disabled = page == 0;
        rightArrow.disabled = Run.inst.roster.length <= diff + 12;
    }

    function select (num:Int) {
        selectedIndex = page * 12 + num;

        final item = Run.inst.roster[selectedIndex];
        guy.dna = item;
        hpText.setText('hp: ${item.hp}');
        rdText.setText('rd: ${item.rad}');

        winText.setText('win: ${item.wins}');
        genText.setText('gen: ${item.generation}');
        // rdText.setText('rd: ${67}');

        // gross!
        nameText.setText(item.name);
        final child = oChildren.filter(o -> o.el == nameText)[0];
        child.x = 256 - nameText.textWidth;

        docile.visible = item.docile;
        coward.visible = item.coward;

        genes.genes = item.genes;

        selected = item;
        onSet(selectedIndex);
    }

    public function deselect () {
        selectedIndex = -1;

        guy.dna = null;
        hpText.setText('');
        rdText.setText('');

        winText.setText('');
        genText.setText('');

        nameText.setText('');

        genes.unset();

        selected = null;
        onSet(-1);
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

    // function addUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void):TextButton {
    //     final uiButton = makeUiTextButton(0, 0, width, height, tileIndex, text, callback);
    //     addChild(x, y, uiButton.button);
    //     addUpChild(Std.int(x + uiButton.text.x), Std.int(y + uiButton.text.y), uiButton.text);
    //     return uiButton;
    // }
}

class GuyIcon extends GameObject {
    public var dna:Null<Dna>;
    public var frames:Int = 0;
    public var dead:Bool = false;

    public function new (x:Int = 0, y:Int = 0) {
        this.x = x;
        this.y = y;
    }

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

            final tileIndex = dead ? 144 + dna.eyes : 128 + dna.eyes;
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
