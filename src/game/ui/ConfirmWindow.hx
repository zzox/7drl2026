package game.ui;

import game.scenes.UiScene;
import game.ui.UiText;
import game.ui.UiWindow;

class ConfirmWindow extends UiWindow {
    public static inline final Width:Int = 240;
    public static inline final Height:Int = 120;

    var callback:Void -> Void;

    public function new (x:Int, y:Int, headerText:String, subtext:String, callback:Void -> Void) {
        super(x, y, 'Confirm');

        makeTopBottom(Width, Height);
        makeXButton();

        final mainText = makeBlackText(headerText);
        final bylineText = makeBitmapText(0, 0, subtext, UiScene.Grey);

        // addUpChild(Math.round((Width - mainText.textWidth) / 2), UiWindow.TopHeight + 16, mainText);
        // addUpChild(Math.round((Width - bylineText.textWidth) / 2), UiWindow.TopHeight + 30, bylineText);
        // addUpChild(240, UiWindow.TopHeight + 28, salaryText = makeBlackText());

        addUiTextButton(50, UiWindow.TopHeight + 60, 60, 16, 0, 'Confirm', () -> {
            handleSubmit();
        });
        addUiTextButton(130, UiWindow.TopHeight + 60, 60, 16, 0, 'Cancel', () -> {
            handleClose();
        });
        this.callback = callback;

        flashTime = 1.0;
    }

    function handleSubmit () {
        callback();
        handleClose();
    }
}
