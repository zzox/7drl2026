package game.scenes;

import core.Game;
import game.data.Save;
import game.ui.NumColumn;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Player;
import game.world.Run;
import kha.Assets;

class StatsScene extends UiScene {
    var muteSound:UiElement;
    var muteMusic:UiElement;
    var scrollBg:UiElement;
    var stats:NumColumn;

    override function create () {
        makeTopButtons(4);

        entities.push(new UiElement(18, 32, 16, 16, 4, 4, 12, 12, 280, 128, 20, Assets.images.ui));

        final stats = new NumColumn(24, 32, 100, ['Wins', 'Losses', 'Offspring', 'Abandoned']);
        stats.setStringItem('Wins', '${Run.inst.wins}/${Run.Generations + 1}');
        stats.setItem('Losses', Run.inst.losses);
        stats.setItem('Losses', Run.inst.losses);
        stats.setItem('Offspring', Run.inst.offspring);
        stats.setItem('Abandoned', Run.inst.abandoned);
        entities.push(stats);

        entities.push(makeBitmapText(200, 40, 'Music'));
        entities.push(muteMusic = new UiElement(260, 40, 16, 16, 4, 4, 12, 12, 16, 16, Player.music ? 72 : 76, Assets.images.ui, () -> {
            Player.music = !Player.music;
            Game.bgScene.muteMusic();
            muteMusic.baseIndex = Player.music ? 72 : 76;
            Save.settings.music = Player.music;
            Save.writeSave();
        }));

        entities.push(makeBitmapText(200, 60, 'SFX'));
        entities.push(muteSound = new UiElement(260, 60, 16, 16, 4, 4, 12, 12, 16, 16, Player.sfx ? 72 : 76, Assets.images.ui, () -> {
            Player.sfx = !Player.sfx;
            muteSound.baseIndex = Player.sfx ? 72 : 76;
            Save.settings.sfx = Player.sfx;
            Save.writeSave();
        }));

        entities.push(makeBitmapText(200, 80, 'BG'));
        entities.push(scrollBg = new UiElement(260, 80, 16, 16, 4, 4, 12, 12, 16, 16, !Game.bgScene.invisible ? 88 : 16, Assets.images.ui, () -> {
            if (Game.bgScene.invisible) {
                Game.bgScene.show();
            } else {
                Game.bgScene.clear();
            }

            Save.settings.bgScroll = !Game.bgScene.invisible;
            Save.writeSave();
        }));

        entities.push(makeBitmapText(86, 132, 'Quit Run:'));

        buttons.push(muteMusic);
        buttons.push(muteSound);
        buttons.push(scrollBg);

        buttons.push(makeUiTextButton(180, 132, 40, 16, 16, 'QUIT', () -> {
            game.changeScene(new QuitScene());
        }));
    }

    override function update (delta:Float) {
        super.update(delta);

        muteMusic.baseIndex = Player.music ? 72 : 76;
        muteSound.baseIndex = Player.sfx ? 72 : 76;
        scrollBg.baseIndex = !Game.bgScene.invisible ? 88 : 16;
    }
}
