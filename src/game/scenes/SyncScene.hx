package game.scenes;

import core.Game;
import core.Types;
import core.gameobjects.BitmapText;
import core.gameobjects.GameObject;
import core.gameobjects.NineSlice;
import core.gameobjects.Sprite;
import core.scene.Scene;
import core.system.Camera;
import core.util.Util;
import game.ui.AlertWindow;
import game.ui.ConfirmWindow;
import game.ui.UiButtons;
import game.ui.UiElement;
import game.ui.UiText;
import game.ui.UiWindow;
import game.util.Debug;
import game.util.TextUtil;
import game.world.Run;
import game.world.World;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;

class SyncScene extends Scene {
    var windows:Array<GeneSelectWindow> = [];
    var topButtons:Array<UiElement> = [];

    override function create () {
        new Run();

        trace(Run.inst.pool);

        makeTopButtons();

        windows.push(new GeneSelectWindow(4, 20, 'asdf'));
    }

    override function update (delta:Float) {
        super.update(delta);

        // hovered = false;
        // buttonPressed = false;

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

    function makeTopButtons () {
        final button = makeUiButton(64, 0, 32, 16, 16, () -> { trace('click'); });
        // final icon = new Sprite(DayTimeWidth + pos * 32, 0, Assets.images.ui, 32, 32);
        // icon.tileIndex = imgIndex + 48;
        entities.push(button);
        // entities.push(icon);
        topButtons.push(button);
    }
}

typedef ChildElements = {
    var el:UiElement;
    // var el:GameObject;
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

    public var children:Array<ChildElements> = [];
    var oChildren:Array<OChildElement> = [];

    public var flashTime:Float = 0.0;

    public function new (x:Int, y:Int, name:String, showName:Bool = true) {
        this.x = x;
        this.y = y;
        this.name = name;

        if (showName) addUpChild(4, 2, makeWhiteText(name));

        final topbar = new UiElement(0, 0, 16, 16, 3, 3, 13, 13, width, TopHeight, 12, Assets.images.ui);
        addChild(0, 0, topbar);
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
        for (c in oChildren) {
            c.el.x = x + c.x;
            c.el.y = y + c.y;
            if (c.el.visible) c.el.render(g2, cam);
        }
    }

    function addChild (x:Int, y:Int, el:UiElement) {
        children.push({ x: x, y: y, el: el });
        width = Std.int(Math.max(width, x + el.elementSizeX));
        height = Std.int(Math.max(height, y + el.elementSizeY));
    }

    function addUpChild (x:Int, y:Int, el:GameObject):OChildElement {
        final o = { x: x, y: y, el: el };
        oChildren.push(o);
        return o;
    }
}
