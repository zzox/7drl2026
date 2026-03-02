package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.scene.Scene;
import game.ui.UiText;
import game.util.Debug;
import game.util.TextUtil;
import game.world.World;
import haxe.Json;
import haxe.Timer;
import kha.input.KeyCode;

final json = '[{ temp: 1 }]';

class HarnessScene extends Scene {
    var world:World;
    var worldActive:Bool = true;

    var devTexts:Array<BitmapText> = [];

    var replayCommands:Array<{ step:Int, command: Command }>;

    override function create () {
        super.create();

        // WARN: should go in first scene in the game to initialize these items
        new UiText();

        for (i in 0...20) {
            final text = makeBitmapText(4, 4 + i * 10, '');
            entities.push(text);
            devTexts.push(text);        }

        final parsed = Json.parse(json);
        world = new World(parsed.seed);

        // trace(Std.isOfType(replayCommands, Array<{ step:Int, command: Command }>));
#if debug
    Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end
        // handleCamera();
        // handlePointer(delta);

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new HarnessScene());
        }

        var steps = 1;
        if (Game.keys.justPressed(KeyCode.J)) {
            steps += 10000;
        } else if (Game.keys.justPressed(KeyCode.H)) {
            steps += 1000;
        } else if (Game.keys.justPressed(KeyCode.G)) {
            steps += 200;
        } else if (Game.keys.justPressed(KeyCode.F)) {
            steps += 50;
        }

        if (worldActive) {
            for (_ in 0...steps) {
                var nextItem = replayCommands[0];

                while (nextItem != null && world.time == nextItem.step) {
                    final item = replayCommands.shift();
                    world.doCommand(item.command);
                    nextItem = replayCommands[0];
                }
                // worldActive = world.step();
                // break needed?
                // if (!worldActive) break;
            }
        }

        devTexts[2].setText(world.time + '');
        devTexts[3].setText(TextUtil.formatMoney(world.money));

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
#end
    }
}
