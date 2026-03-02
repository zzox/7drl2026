package game.ui;

import core.gameobjects.BitmapText;
import core.gameobjects.GameObject;
import core.system.Camera;
import game.ui.UiText;
import kha.graphics2.Graphics;

typedef NumColumnItem = {
    var name:String;
    var num:String;
}

class NumColumn extends GameObject {
// var x:Int;
// var y:Int;
    var width:Int;
    var items:Array<NumColumnItem>;
    var yadv:Int;
    var textItem:BitmapText;

    // NOTE: uses the right edge from `width` for now, may need a proper value in the future
    public function new (x:Int, y:Int, width:Int, items:Array<String>, yadv:Int = 10) {        
        final column = [];
        for (item in items) {
            column.push({
                name: item,
                num: '0'
            });
        }

        this.width = width;
        this.textItem = makeWhiteText();
        this.yadv = yadv;
        this.items = column;

        this.x = x;
        this.y = y;
    }

    override function update (delta:Float) {}

    public function setItem (prop:String, val:Int) {
        final item = items.filter(item -> item.name == prop)[0];
        item.num = val + '';
    }

    public function setStringItem (prop:String, val:String) {
        final item = items.filter(item -> item.name == prop)[0];
        item.num = val;
    }

    override function render (g2:Graphics, cam:Camera) {
        var yy = y;
        for (i in 0...items.length) {
            textItem.setText(items[i].name);
            textItem.setPosition(x, yy);
            textItem.render(g2, cam);
            textItem.setText(items[i].num);
            textItem.setPosition(x + width - textItem.textWidth - 4, yy);
            textItem.render(g2, cam);
            yy += yadv;
        }
    }
}