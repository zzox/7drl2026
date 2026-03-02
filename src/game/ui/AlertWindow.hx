package game.ui;

import game.scenes.UiScene;
import game.ui.UiText;
import game.ui.UiWindow;

class AlertWindow extends UiWindow {
    static inline final Width:Int = 180;
    static inline final Height:Int = 120;

    // var callback:Void -> Void;

    public function new (x:Int, y:Int, headerText:String, subtext:String) {
        super(x, y, 'Alert');

        final mainText = makeBlackText(headerText);
        final bylineText = makeBitmapText(0, 0, subtext, UiScene.Grey);

        final w = Std.int(Math.max(Math.max(mainText.textWidth, bylineText.textWidth), Width) + 16);

        makeTopBottom(w, Height);
        makeXButton();

        addUpChild(Math.round((width - mainText.textWidth) / 2), UiWindow.TopHeight + 16, mainText);
        addUpChild(Math.round((width - bylineText.textWidth) / 2), UiWindow.TopHeight + 30, bylineText);

        addUiTextButton(Math.round((width - 60) / 2), UiWindow.TopHeight + 60, 60, 16, 0, 'Ok', () -> {
            handleClose();
        });

        flashTime = 2.0;
    }
}
