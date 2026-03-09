package game.ui;

import core.gameobjects.BitmapText;
import core.util.BitmapFont;
import kha.Assets;

class UiText {
    public static var hopeGold:FntBitmapFont;
    public static var smallFont:ConstructBitmapFont;

    public function new () {
        hopeGold = makeFont();
        smallFont = makeSmallFont();
    }
}

function makeFont ():FntBitmapFont {
    return new FntBitmapFont(Assets.blobs.hope_gold_fnt.toString());
}

function makeSmallFont ():ConstructBitmapFont {
    return new ConstructBitmapFont(
        8, 8,
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,$:?!"\'+-=*%_() ',
        [
            [6, '$'],
            [5, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?"+-=*%_()'],
            [3, ' '],
            [3, '.,;:!\''],
        ],
        -2
    );
}

function makeBitmapText (posX:Int, posY:Int, text:String = '', color:Int = 0xffffff):BitmapText {
    final bmpTxt = new BitmapText(posX, posY, Assets.images.hope_gold, UiText.hopeGold, text);
    bmpTxt.color = color;
    return bmpTxt;
}

function makeWhiteText (str:String = '') {
    return makeBitmapText(0, 0, str, 0xffffff);
}

function makeBlackText (str:String = '') {
    return makeBitmapText(0, 0, str, 0x000000);
}
