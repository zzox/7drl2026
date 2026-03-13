package game.scenes;

import core.Game;
import game.ui.NumColumn;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Player;
import game.world.Run;
import kha.Assets;

class StatsScene extends UiScene {
    var muteSound:UiElement;
    var muteMusic:UiElement;
    var stats:NumColumn;

    override function create () {
        makeTopButtons(4);

        entities.push(new UiElement(18, 32, 16, 16, 4, 4, 12, 12, 280, 128, 20, Assets.images.ui));

        final stats = new NumColumn(24, 32, 100, ['Wins', 'Losses', 'Offspring', 'Abandoned']);
        stats.setItem('Wins', Run.inst.wins);
        stats.setItem('Losses', Run.inst.losses);
        stats.setItem('Losses', Run.inst.losses);
        stats.setItem('Offspring', Run.inst.offspring);
        stats.setItem('Abandoned', Run.inst.abandoned);
        entities.push(stats);

        entities.push(makeBitmapText(200, 40, 'Music'));
        entities.push(muteMusic = new UiElement(260, 40, 16, 16, 4, 4, 12, 12, 16, 16, Player.sfx ? 72 : 76, Assets.images.ui, () -> {
            Player.music = !Player.music;
            Game.bgScene.muteMusic();
            muteMusic.baseIndex = Player.music ? 72 : 76;
        }));

        entities.push(makeBitmapText(200, 60, 'SFX'));
        entities.push(muteSound = new UiElement(260, 60, 16, 16, 4, 4, 12, 12, 16, 16, Player.sfx ? 72 : 76, Assets.images.ui, () -> {
            Player.sfx = !Player.sfx;
            muteSound.baseIndex = Player.sfx ? 72 : 76;
        }));

        entities.push(makeBitmapText(86, 132, 'Quit Run:'));

        buttons.push(muteMusic);
        buttons.push(muteSound);
        buttons.push(makeUiTextButton(180, 132, 40, 16, 16, 'QUIT', () -> {
            game.changeScene(new QuitScene());
        }));
    }
}
