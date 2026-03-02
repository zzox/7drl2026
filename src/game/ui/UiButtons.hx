package game.ui;

import core.gameobjects.BitmapText;
import core.gameobjects.Sprite;
import game.ui.UiText;
import kha.Assets;

typedef TextButton = {
    var button:UiElement;
    var text:BitmapText;
}

function makeUiButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, callback:Void -> Void):UiElement {
    final button = new UiElement(x, y, 16, 16, 3, 3, 13, 13, width, height, tileIndex, Assets.images.ui, callback);
    return button;
}

function makeUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void):TextButton {
    final button = new UiElement(x, y, 16, 16, 3, 3, 13, 13, width, height, tileIndex, Assets.images.ui, callback);
    final text = makeBlackText(text);
    text.setPosition(x + Math.floor((width - text.textWidth) / 2), y);
    return { button: button, text: text };
}

function makeStaticSprite (x:Int, y:Int, width:Int, height:Int, tileIndex:Int):Sprite {
    final sprite = new Sprite(x, y, Assets.images.ui, width, height);
    sprite.tileIndex = tileIndex;
    return sprite;
}
