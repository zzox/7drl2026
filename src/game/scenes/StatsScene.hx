package game.scenes;

import core.Game;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Player;
import game.world.Run;
import kha.Assets;

class StatsScene extends UiScene {
    var muteSound:UiElement;
    var muteMusic:UiElement;

    override function create () {
        makeTopButtons(4);

        entities.push(new UiElement(18, 32, 16, 16, 4, 4, 12, 12, 280, 128, 20, Assets.images.ui));

        entities.push(makeBitmapText(64, 88, 'Music:'));
        entities.push(muteMusic = new UiElement(100, 88, 16, 16, 4, 4, 12, 12, 16, 16, Player.sfx ? 72 : 76, Assets.images.ui, () -> {
            Player.music = !Player.music;
            Game.bgScene.muteMusic();
            muteMusic.baseIndex = Player.music ? 72 : 76;
        }));

        entities.push(makeBitmapText(64, 108, 'SFX:'));
        entities.push(muteSound = new UiElement(100, 108, 16, 16, 4, 4, 12, 12, 16, 16, Player.sfx ? 72 : 76, Assets.images.ui, () -> {
            Player.sfx = !Player.sfx;
            muteSound.baseIndex = Player.sfx ? 72 : 76;
        }));

        entities.push(makeBitmapText(86, 132, 'Abandon Run:'));
        final item = makeUiTextButton(180, 132, 40, 16, 16, 'QUIT', () -> {
            game.changeScene(new MenuScene());
            // game.changeScene(new ReallyQuitScene());
        });
        item.altSound = Assets.sounds.sons_fx2;

        buttons.push(muteMusic);
        buttons.push(muteSound);
        buttons.push(item);
    }
}
