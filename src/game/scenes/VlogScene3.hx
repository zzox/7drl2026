package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Debug;
import game.world.Dna;
import game.world.Run;
import game.world.World.simulateBattle;
import haxe.Timer;
import kha.Assets;
import kha.input.KeyCode;

typedef DnaData = {
    var w:Int;
    var l:Int;
    var t:Int;
    var dna:Dna;
}

function score (dna:DnaData) {
    return dna.w * 3 + dna.t;
}

class VlogScene3 extends ButtonScene {
    var page:Int = 0;
    var maxPages:Int = 0;

    static var matches:Map<String, Bool> = new Map();
    static var dnas:Null<Array<DnaData>>;
    static var matchNum:Int;

    var logTexts:Array<BitmapText> = [];
    override function create () {
        super.create();

        final time = Timer.stamp();

        logTexts[0] = makeBitmapText(4, 4, '');
        logTexts[1] = makeBitmapText(84, 4, '');
        logTexts[2] = makeBitmapText(164, 4, '');

        entities.push(logTexts[0]);
        entities.push(logTexts[1]);
        entities.push(logTexts[2]);

        if (dnas == null) {
            new Run();

            matchNum = Run.inst.world.matches;

            final list = Lambda.flatten(Run.inst.world.geneCopies);

            dnas = list.map(d -> {
                return {
                    w: 0, l: 0, t: 0, dna: d
                }
            });

            for (d1 in dnas) {
                for (d2 in dnas) {
                    if (d2 != d1 && !matches.get('${d2.dna.id}:${d1.dna.id}')) {
                        final res = simulateBattle(d1.dna, d2.dna);
                        if (res == Tie) {
                            d1.t++;
                            d2.t++;
                        } else if (res == OneWin) {
                            d1.w++;
                            d2.l++;
                        } else if (res == TwoWin) {
                            d2.w++;
                            d1.l++;
                        }

                        matchNum++;
                        matches.set('${d1.dna.id}:${d2.dna.id}', true);
                    }
                }
            }

            dnas.sort((d1, d2) -> {
                return score(d2) - score(d1);
            });
        }

        maxPages = Math.ceil(dnas.length / 12);

        show();

        trace(Timer.stamp() - time);

#if debug
    Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end

        if (Game.keys.justPressed(KeyCode.Up)) {
            page = --page;
            if (page < 0) {
                page = maxPages - 1;
            }
            show();
        }

        if (Game.keys.justPressed(KeyCode.Down)) {
            page = ++page % maxPages;
            show();
        }

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new VlogScene3());
        }

        if (Game.keys.justPressed(KeyCode.X)) {
            game.changeScene(new StandaloneBattleScene(dnas[0].dna, dnas[1].dna));
        }

        logTexts[0].setText('M: ${matchNum}, D: ${dnas.length}, p${page}');

        super.update(delta);

#if debug
        final time = Timer.stamp();
        final updateTime = time - updateStart;
        Debug.updateTimes.push(updateTime);
        Debug.updateTimes.shift();

        Debug.updateFrames.push(time);
        while (true) {
            if (Debug.updateFrames[0] != null && Debug.updateFrames[0] < time - 0.999) {
                Debug.updateFrames.shift();
            } else {
                break;
            }
        }

        final highest = Lambda.fold(Debug.updateTimes, (frame, res) -> Math.max(frame, res), 0);
        logTexts[2].setText('UPS: ${Debug.updateFrames.length}, avg: ${Math.round(average(Debug.updateTimes) * 1000)}ms, hi: ${Math.round(highest * 1000)}ms');
#end
    }

    function show () {
        entities = entities.slice(0, 3);
        buttons.resize(0);
        
        var pos = 0;
        for (i in (page * 12)...((page + 1) * 12)) {
            final gene = dnas[i];
            if (gene != null) {
                final el = new UiElement(2, 50 + 10 * pos, 16, 16, 3, 3, 13, 13, 12 * 24, 12, 16, Assets.images.ui, () -> {
                    doSomething(gene.dna);
                });
                buttons.push(el);
                entities.push(el);
                entities.push(new GenesDisplay(2, 50 + 10 * pos, gene.dna.genes, 24));
                entities.push(makeBitmapText(204, 46 + 10 * pos, 'p: ${score(gene)}, w/t ${gene.w}/${gene.t}'));
            }
            pos++;

        }
    }

    function doSomething (dna:Dna) {
        trace(dna);
    }
}
