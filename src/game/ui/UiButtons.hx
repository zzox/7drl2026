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
    final button = new UiElement(x, y, 16, 16, 4, 4, 12, 12, width, height, tileIndex, Assets.images.ui, callback);
    return button;
}
