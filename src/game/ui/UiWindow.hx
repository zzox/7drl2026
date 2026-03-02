package game.ui;

import core.Types;
import core.gameobjects.BitmapText;
import core.gameobjects.GameObject;
import core.system.Camera;
import game.scenes.GameScene;
import game.scenes.UiScene;
import game.ui.BarEl;
import game.ui.UiButtons;
import game.ui.UiElement;
import game.ui.UiText;
import kha.Assets;
import kha.graphics2.Graphics;

typedef ChildElements = {
    var el:UiElement;
    // var el:GameObject;
    var x:Int;
    var y:Int;
}
// TODO: combine these somehow
typedef OChildElement = {
    // var el:UiElement;
    var el:GameObject;
    var x:Int;
    var y:Int;
}

typedef NumColumnItem = {
    var name:String;
    var num:String;
}
typedef NumColumn = {
    var x:Int;
    var y:Int;
    var width:Int;
    var items:Array<NumColumnItem>;
    var yadv:Int;
    var textItem:BitmapText;
}

// a collection of gameobjects all rendered to a relative position
class UiWindow {
    public static var TopHeight:Int = 20;

    public var x:Int;
    public var y:Int;
    public var name:String;

    public var width:Int = 0;
    public var height:Int = 0;

    // parent will close when set to true
    public var closed:Bool = false;

    public var heldPos:Null<IntVec2>;

    public var children:Array<ChildElements> = [];
    public var grabbable:Null<UiElement>;
    public var cancel:Null<UiElement>;
    var oChildren:Array<OChildElement> = [];

    public var flashTime:Float = 0.0;

    public function new (x:Int, y:Int, name:String, showName:Bool = true) {
        this.x = x;
        this.y = y;
        this.name = name;

        // TODO: scoot right for top bar images
        if (showName) addUpChild(4, 2, makeWhiteText(name));
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

        if (flashTime > 0.0 && grabbable != null) {
            grabbable.tileIndex = GameScene.shortPulseOn ? 12 : 13;
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

    inline function makeTopBottom(width:Int, height:Int) {
        // these are all at 0,0 because they'll be positioned in `render`
        final topbar = new UiElement(0, 0, 16, 16, 3, 3, 13, 13, width, TopHeight, 12, Assets.images.ui);
        final bottomBg = new UiElement(0, 0, 16, 16, 3, 3, 13, 13, width, height - TopHeight, 0, Assets.images.ui);

        addChild(0, 0, topbar);
        addChild(0, TopHeight, bottomBg);

        grabbable = topbar;
    }
    inline function makeXButton () {
        final xButton = new XButton(handleClose);
        addChild(width - 17, 3, xButton);
    }

    inline function makeBar (x:Int, y:Int, width:Int, height:Int, colors:Array<BarColor>, value:Int, max:Int, ?pulseWindows:PulseWindows):BarEl {
        final downEl = new UiElement(0, 0, 16, 16, 2, 2, 14, 14, width, height, 4, Assets.images.ui);
        final barEl = new BarEl(0, 0, 16, 16, 2, 2, 14, 14, width, height, colors, value, max, pulseWindows);

        addChild(x, y, downEl);
        addChild(x, y, barEl);

        // if (label) {}
        return barEl;
    }

    // NOTE: uses the right edge from `width` for now, may need a proper value in the future
    inline function makeNumColumn (x:Int, y:Int, width:Int, items:Array<String>, yadv:Int = 10):NumColumn {
        final column = [];
        for (item in items) {
            column.push({
                name: item,
                num: '0'
            });
        }
        return {
            x: x, y: y,
            width: width,
            textItem: makeBlackText(),
            yadv: yadv,
            items: column
        }
    }

    inline function setNumColumn (column:NumColumn, prop:String, val:Int) {
        final item = column.items.filter(item -> item.name == prop)[0];
        item.num = val + '';
    }

    inline function setNumColumnString (column:NumColumn, prop:String, val:String) {
        final item = column.items.filter(item -> item.name == prop)[0];
        item.num = val;
    }

    inline function renderNumColumn (column:NumColumn, x:Int, y:Int, g2:Graphics, cam:Camera) {
        var y = y + column.y;
        for (i in 0...column.items.length) {
            column.textItem.setText(column.items[i].name);
            column.textItem.setPosition(x + column.x, y);
            column.textItem.render(g2, cam);
            column.textItem.setText(column.items[i].num);
            column.textItem.setPosition(x + column.width - column.textItem.textWidth - 4, y);
            column.textItem.render(g2, cam);
            y += column.yadv;
        }
    }

    function addUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void):TextButton {
        final uiButton = makeUiTextButton(0, 0, width, height, tileIndex, text, callback);
        addChild(x, y, uiButton.button);
        addUpChild(Std.int(x + uiButton.text.x), Std.int(y + uiButton.text.y), uiButton.text);
        return uiButton;
    }

    inline function setTextButtonVisible (textButton:TextButton, visible:Bool) {
        textButton.button.visible = visible;
        textButton.text.visible = visible;
    }

    public function handleClose () {
        closed = true;
    }
}

// TODO: move to ui utils file
class XButton extends UiElement {
    public function new (callback:UiEvent) {
        super(0, 0, 16, 16, 3, 3, 13, 13, 14, 14, 28, Assets.images.ui, callback);
    }
}
