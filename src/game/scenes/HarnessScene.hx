package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.scene.Scene;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Debug;
import game.world.World;
import haxe.Json;
import haxe.Timer;
import kha.input.KeyCode;

final json = '[{ temp: 1 }]';

class HarnessScene extends Scene {
    var world:World;
    // var worldActive:Bool = true;

    var devTexts:Array<BitmapText> = [];

    var genes1:GenesDisplay;
    var genes2:GenesDisplay;

    var replayCommands:Array<{ step:Int, command: Command }>;

    override function create () {
        super.create();

        // WARN: should go in first scene in the game to initialize these items
        new UiText();

        for (i in 0...20) {
            final text = makeBitmapText(4, 4 + i * 10, '');
            entities.push(text);
            devTexts.push(text);
        }

        // final parsed = Json.parse(json);
        // world = new World(parsed.seed);
        world = new World();

        entities.push(genes1 = new GenesDisplay(4, 60, world.room.actors[0].dna.genes, 24));
        entities.push(genes2 = new GenesDisplay(4, 70, world.room.actors[1].dna.genes, 24));

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

        var steps = 100000;
        if (Game.keys.pressed(KeyCode.S)) {
            steps = 0;
        }

        if (Game.keys.pressed(KeyCode.D)) {
            steps = 16;
        }

        for (_ in 0...steps) {
            world.room.step(0);
            final dead = world.room.checkDead();
            if (dead > 0) {
                if (dead == 2) throw 'Both Dead';
                world.nextRoom();
                break;
            }
            if (world.room.checkSkip()) {
                world.nextRoom();
                break;
            }
        }

        genes1.dIndex = world.room.actors[0].dnaIndex;
        genes2.dIndex = world.room.actors[1].dnaIndex;

        genes1.genes = world.room.actors[0].dna.genes;
        genes2.genes = world.room.actors[1].dna.genes;

        devTexts[0].setText('${world.matches}');
        devTexts[1].setText('${world.pool.length}');
        devTexts[2].setText('${world.room.actors[0].dna.id},${world.room.actors[1].dna.id}');
        devTexts[3].setText('${world.room.steps}');

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
