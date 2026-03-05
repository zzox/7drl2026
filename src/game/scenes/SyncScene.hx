package game.scenes;

import core.Game;
import core.gameobjects.GameObject;
import core.scene.Scene;
import core.system.Camera;
import game.ui.UiButtons;
import game.ui.UiElement;
import game.ui.UiText;
import game.world.Dna;
import game.world.Run;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;

class SyncScene extends Scene {
    var windows:Array<GeneSelectWindow> = [];
    var topButtons:Array<UiElement> = [];

    var topGuy:GeneSelectWindow;

    override function create () {
        new UiText();
        new Run();

        trace(Run.inst.pool);

        makeTopButtons(1);

        topGuy = new GeneSelectWindow(4, 20, 'asdf');
        windows.push(topGuy);

        for (i in 0...topGuy.items.length) {
            if (Run.inst.pool[i] != null) {
                topGuy.items[i].button.disabled = false;
                topGuy.items[i].icon.dna = Run.inst.pool[i];
            } else {
                topGuy.items[i].button.disabled = true;
                topGuy.items[i].icon.dna = null;
            }
        }
    }

    override function update (delta:Float) {
        super.update(delta);

        // hovered = false;
        // buttonPressed = false;
        Mouse.get().setSystemCursor(MouseCursor.Default);

        // check top buttons first
        for (button in topButtons) {
            button.checkPointer(Game.mouse.position.x, Game.mouse.position.y);
            if (!button.disabled && button.onClick != null) {
                button.setIndexFromState();
                if (button.hovered) {
                    // hovered = true;
                    Mouse.get().setSystemCursor(MouseCursor.Pointer);
                }
                if (button.pressed) {
                    // buttonPressed = true;
                    Mouse.get().setSystemCursor(MouseCursor.Pointer);
                }
            }

            // mark if we hovered over any of these or if an item was pressed
            // if (b.button.pressed) {
            //     hovered = true;
            // }
        }

        for (win in windows) {
            for (c in win.children) {
                // for every button update state and set the tile index if it has a onclick,
                // we assume it is a button.
                if (!c.el.disabled && c.el.visible) {
                    c.el.checkPointer(Game.mouse.position.x, Game.mouse.position.y);
                    if (c.el.onClick != null) {
                        c.el.setIndexFromState();
                        if (c.el.hovered) {
                            Mouse.get().setSystemCursor(MouseCursor.Pointer);
                        }
                        if (c.el.pressed) {
                            // buttonPressed = true;
                            Mouse.get().setSystemCursor(MouseCursor.Pointer);
                        }
                    }
                } else if (c.el.disabled) {
                    c.el.setIndexFromState();
                }

                win.update(delta);
            }
        }
    }

    override function render (g2:Graphics, clears:Bool) {
        g2.begin(true, camera.bgColor);
        for (e in entities) {
            if (e.visible) e.render(g2, camera);
        }
        for (win in windows) win.render(g2, camera);
        g2.end();
    }

    // TODO: following to parent scene
    function makeTopButtons (sceneIndex:Int) {
        // final button = makeUiButton(64, 0, 32, 16, 16, () -> { trace('click'); });
        // final icon = new Sprite(DayTimeWidth + pos * 32, 0, Assets.images.ui, 32, 32);
        // icon.tileIndex = imgIndex + 48;

        topButtons.push(makeUiTextButton(100, 0, 40, 16, 16, 'BTTL', () -> {
            trace('clicked!');
        }));

        topButtons.push(makeUiTextButton(140, 0, 40, 16, 16, 'SYNC', sceneIndex == 1 ? () -> {
            trace('play sound!');
        } : () -> {
            trace('go scene');
        }));

        topButtons.push(makeUiTextButton(180, 0, 40, 16, 16, 'SHOP', () -> {
            trace('clicked!');
        }));

        // entities.push(icon);
        // entities.push(button);
    }
    function makeUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void) {
        final button = new UiElement(x, y, 16, 16, 3, 3, 13, 13, width, height, tileIndex, Assets.images.ui, callback);
        final text = makeWhiteText(text);
        text.setPosition(x + Math.floor((width - text.textWidth) / 2), y);
        entities.push(button);
        entities.push(text);
        return button;
    }
}

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
    public static var TopHeight:Int = 20;

    public var x:Int;
    public var y:Int;
    public var name:String;

    public var width:Int = 0;
    public var height:Int = 0;

    public var children:Array<ChildElement> = [];
    var oChildren:Array<OChildElement> = [];

    public var selectedIndex:Int = -1;
    public var items:Array<{ button:UiElement, icon:GuyIcon }> = [];

    public var flashTime:Float = 0.0;

    public function new (x:Int, y:Int, name:String) {
        this.x = x;
        this.y = y;
        this.name = name;

        final bg = new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 280, 72, 21, Assets.images.ui);
        addChild(0, 0, bg);

        makeIcons();

        addUpChild(4, 2, makeWhiteText(name));
    }

    function makeIcons () {
        for (i in 0...24) {
            final row = Math.floor(i / 12);
            final col = i % 12;

            final button = makeUiButton(0, 0, 20, 20, 24, () -> {
                select(i);
            });
            final icon = new GuyIcon();

            addChild(4 + 20 * col, 32 + 20 * row, button);
            addUpChild(4 + 20 * col + 2, 32 + 20 * row + 2, icon);

            items.push({ button: button, icon: icon });
        }
    }

    function select (num:Int) {
        selectedIndex = num;
        trace(Run.inst.pool[num]);
    }

    public function update (delta:Float) {
        for (c in children) c.el.update(delta);
        for (c in oChildren) c.el.update(delta);
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

    function addUpChild (x:Int, y:Int, el:GameObject) {
        oChildren.push({ x: x, y: y, el: el });
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

            // g2.pushRotation(
            //     getRotDir(actor.facing) + toRadians(90),
            //     actor.x * sizeX + 8,
            //     actor.y * sizeY + 8
            // );

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
            // g2.popTransformation();
        }
    }
}
