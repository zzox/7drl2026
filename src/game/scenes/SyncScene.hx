package game.scenes;

import core.gameobjects.BitmapText;
import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiElement;
import game.ui.UiText;
import game.world.Run;

class SyncScene extends UiScene {
    var partner1:GeneSelectWindow;
    var partner2:GeneSelectWindow;

    var syncButton:UiElement;
    var cancelButton:UiElement;

    var g1:GenesDisplay;
    var g2:GenesDisplay;

    var syncText:BitmapText;

    override function create () {
        // trace(Run.inst.roster);
        super.create();

        makeTopButtons(1);

        windows.push(partner1 = new GeneSelectWindow(18, 16, 'Partner 1', (num:Int) -> {
            if (num > -1) {
                partner2.visible = true;
                g1.genes = partner1.selected.genes;
                if (partner2.selected == partner1.selected) {
                    setSyncText('Cannot self sync');
                } else if (partner2.selected == null) {
                    setSyncText('Pick partner 2');
                } else {
                    setSyncText('');
                }
            } else {
                g1.genes = [];
            }
        }));
        windows.push(partner2 = new GeneSelectWindow(18, 76, 'Partner 2', (num:Int) -> {
            if (num > -1) {
                g2.genes = partner2.selected.genes;
                if (partner2.selected == partner1.selected) {
                    setSyncText('Cannot self sync');
                } else {
                    setSyncText('');
                }
            } else {
                setSyncText('Pick partner 2');
                g2.genes = [];
            }
        }));
        partner2.visible = false;

        syncButton = makeUiTextButton(44, 162, 40, 16, 16, 'SYNC', () -> {
            Run.inst.makeNursery(partner2.selected, partner1.selected);
            game.changeScene(new NurseryScene());
        });

        cancelButton = makeUiTextButton(236, 162, 40, 16, 16, 'CNCL', () -> {
            partner1.deselect();
            partner2.deselect();
            partner2.visible = false;
            setSyncText('Pick partner 1');
        });

        entities.push(syncText = makeBitmapText(86, 162, ));
        setSyncText('Pick partner 1');

        g1 = new GenesDisplay(64, 142, [], 24);
        g2 = new GenesDisplay(64, 152, [], 24);

        entities.push(g1);
        entities.push(g2);

        buttons.push(syncButton);
        buttons.push(cancelButton);
    }

    override function update (delta:Float) {
        cancelButton.disabled = partner1.selectedIndex == -1;
        syncButton.disabled = partner2.selectedIndex == -1 || partner1.selected == partner2.selected;
        super.update(delta);
    }

    function setSyncText (text:String) {
        syncText.setText(text);
        syncText.x = 160 - Math.floor(syncText.textWidth / 2);
    }
}
