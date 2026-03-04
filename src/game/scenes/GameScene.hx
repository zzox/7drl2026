package game.scenes;

import core.Game;
import core.Types;
import core.gameobjects.BitmapText;
import core.scene.Scene;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.NumColumn;
import game.ui.RoomRender;
import game.ui.UiText;
import game.util.Debug;
import game.world.Actor;
import game.world.Room.RoomEvent;
import game.world.Thing;
import game.world.World;
import haxe.Json;
import haxe.Timer;
import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.input.Mouse;

final TILE_WIDTH = 16;
final TILE_HEIGHT = 8;

typedef RenderItem = {
    var x:Float;
    var y:Float;
    var tileIndex:Int;
    var shadow:Int;
    var flipX:Bool;
    var alpha:Int;
    var color:Int;
}

typedef RenderedActor = {
    var x:Float;
    var y:Float;
    var actor:Actor;
}
typedef RenderedThing = {
    var x:Float;
    var y:Float;
    var thing:Thing;
}

class GameScene extends Scene {
    public static final White:Int = 256 * 0x1000000 + 0xffffffff;

    static var pulseTime:Float = 0.0;
    public static var pulseOn:Bool = true;
    public static var shortPulseOn:Bool = true;

    var world:World;
    // var particles:Particle;
    // var uiScene:UiScene;
    // var logs:Logs;
    var worldActive:Bool = true;
    var tilePosAt:IntVec2 = new IntVec2(0, 0);

    var stepText:BitmapText;
    var winsText:BitmapText;
    var char1:NumColumn;
    var char2:NumColumn;
    var genes1:GenesDisplay;
    var genes2:GenesDisplay;

    var renderedActors:Array<RenderedActor> = [];
    var renderedThings:Array<RenderedThing> = [];
    // var numbers:Array<Particle> = [];
    var particles:Array<Particle> = [];

    var selectedActor:Null<Actor>;
    var selectedThing:Null<Thing>;

    var gameId:String;

    // DEBUG:
    var wins:Int = 0;

#if debug
    public var devTexts:Array<BitmapText> = [];
#end

    override function create () {
        super.create();

        // WARN: should go in first scene in the game to initialize these items
        new UiText();

        gameId = (Math.random() + '').split('.')[1];
        world = new World();

        // logs = new Logs();

        // uiScene = new UiScene(this, world, logs);
        // game.addScene(uiScene);

        entities.push(winsText = makeBitmapText(100, 16, 'Wins: 0'));
        entities.push(stepText = makeBitmapText(160, 16, 'Steps: 0'));

        entities.push(char1 = new NumColumn(24, 24, 60, ['hp', 'speed', 'dindex', 'p', 'id'], 10));
        entities.push(char2 = new NumColumn(240, 24, 60, ['hp', 'speed', 'dindex', 'p', 'id'], 10));

        entities.push(genes1 = new GenesDisplay(16, 108, world.room.actors[0].dna.genes));
        entities.push(genes2 = new GenesDisplay(230, 108, world.room.actors[1].dna.genes));

        // for (_ in 0...20) {
        //     numbers.push(new Particle());
        // }

#if debug
        for (i in 0...8) {
            final text = makeBitmapText(0, 74 + i * 10, '');
            entities.push(text);
            devTexts.push(text);
            // text.visible = false;
        }

        Debug.renderTimes = [for (i in 0...300) 0.0]; // 5 seconds on 60fps monitors
        Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end
        handlePointer(delta);

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new GameScene());
        }

        if (Game.keys.justPressed(KeyCode.O)) {
            trace(getData());
        }

        if (Game.keys.justPressed(KeyCode.P)) {
            worldActive = !worldActive;
        }

        var steps = 4;
        if (Game.keys.pressed(KeyCode.J)) {
            steps += 4096;
        } else if (Game.keys.pressed(KeyCode.H)) {
            steps += 512;
        } else if (Game.keys.pressed(KeyCode.G)) {
            steps += 128;
        } else if (Game.keys.pressed(KeyCode.F)) {
            steps += 16;
        }

        if (worldActive) {
            // turns speed 0 into 1, speed 1 into 4 and speed 2 into 16
            // steps *= Std.int(Math.pow(2, uiScene.ffSpeed));
            // steps *= Std.int(Math.pow(2, uiScene.ffSpeed));
            // if (uiScene.ffSpeed >= 1) steps *= 2;
            // if (uiScene.ffSpeed >= 2) steps *= 2;
            for (_ in 0...steps) {
                world.room.step(0);
                updateParticles();
                final dead = world.room.checkDead();
                if (dead > 0) {
                    if (dead == 2) throw 'Both Dead';
                    nextRoom(false);
                    break;
                }
                // DEBUG: for testing tournaments we speed through it
                if (world.room.checkSkip()) {
                    nextRoom(true);
                }
            }
            // WARN: overflow from too many events?
            handleEvents(world.room.getEvents());
        }

        winsText.setText('Wins: ${wins}');
        stepText.setText('Steps: ${world.room.steps}');

        char1.setStringItem('hp', '${world.room.actors[0].hp}/${world.room.actors[0].dna.hp}');
        char1.setItem('speed', world.room.actors[0].dna.speed);
        char1.setItem('dindex', world.room.actors[0].dnaIndex);
        char1.setStringItem('p', '${world.room.actors[0].x},${world.room.actors[0].y},${world.room.actors[0].facing}');
        char1.setItem('id', world.room.actors[0].dna.id);
        char2.setStringItem('hp', '${world.room.actors[1].hp}/${world.room.actors[1].dna.hp}');
        char2.setItem('speed', world.room.actors[1].dna.speed);
        char2.setItem('dindex', world.room.actors[1].dnaIndex);
        char2.setStringItem('p', '${world.room.actors[1].x},${world.room.actors[1].y},${world.room.actors[1].facing}');
        char2.setItem('id', world.room.actors[1].dna.id);

        genes1.dIndex = world.room.actors[0].dnaIndex;
        genes2.dIndex = world.room.actors[1].dnaIndex;

        pulseTime = (pulseTime + delta) % 0.5;
        pulseOn = pulseTime < 0.25;
        shortPulseOn = (pulseTime % 0.25) < 0.125;

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

    override function render (g2:Graphics, clears:Bool) {
#if debug
        final renderStart = Timer.stamp();
#end
        // PERF: only do this on rotation instead of on every frame, preferably
        // rendering to a single image
        g2.begin(true, camera.bgColor);

        // g2.color = Math.floor(alpha * 256) * 0x1000000 + color;
        g2.color = White;

        g2.pushTranslation(-camera.scrollX, -camera.scrollY);
        g2.pushScale(camera.scale, camera.scale);

        roomRender(g2, 100, 32, world.room, particles);

        final charXDiff = 0;
        final charYDiff = 20;
 
        // ATTN: is this the best way to handle selecting rendered actors?
        renderedActors.resize(0);
        renderedThings.resize(0);
        // var renderItems:Array<RenderItem> = world.rooms[focusedRoom].actors.map(actor -> {
        //     var tileIndex = 0;

        //     // figure facing
        //     final facingDir = calculateFacing(actor.facing);

        //     final x = translateWorldX(actor.x, actor.y);
        //     final y = translateWorldY(actor.x, actor.y);

        //     renderedActors.push({ x: x, y: y, actor: actor });

        //     return {
        //         x: x, y: y,
        //         alpha: 0xff,
        //         tileIndex: tileIndex,
        //         color: actor == selectedActor ? 0xffff00 : getLightColor(getGridItem(world.rooms[focusedRoom].lights, actor.getX(), actor.getY())),
        //         flipX: flipX,
        //         shadow: shadowIndex,
        //     }
        // });

        // renderItems = renderItems.concat(world.rooms[focusedRoom].thingPieces.map(p -> {
        //     final facingDir = calculateFacing(p.rotation);
        //     final tileIndex = pieceData.get(p.type) + facingDir;

        //     final x = translateWorldX(p.x, p.y);
        //     final y = translateWorldY(p.x, p.y);

        //     renderedThings.push({ x: x, y: y, piece: p });

        //     return {
        //         x: x, y: y,
        //         alpha: selectedThing == p.parent ? 0x80 : 0xff,
        //         tileIndex: tileIndex,
        //         color: isLight(p) ? 0xffffff : getLightColor(getGridItem(world.rooms[focusedRoom].lights, p.x, p.y)),
        //         // if we want to change color on selelction
        //         // color: selectedThing == p.parent && selectedActor == null ? 0xffff00 : 0xffffff,
        //         flipX: false,
        //         shadow: isBr(p.parent) ? emptyIndex : shadowIndex + 1,
        //         // shadow: true
        //     }
        // }));

        // tile size here
        final sizeX = 16;
        final sizeY = 16;

        // final image = Assets.images.char;

        // for (i in 0...renderItems.length) {
        //     final item = renderItems[i];

        //     final cols = Std.int(image.width / sizeX);
        //     // render actor/thing
        //     g2.color = item.alpha * 0x1000000 + item.color;
        //     g2.drawScaledSubImage(
        //         image,
        //         (item.tileIndex % cols) * sizeX, Math.floor(item.tileIndex / cols) * sizeY, sizeX, sizeY,
        //         // item.x + (item.flipX ? sizeX : 0)), item.y,
        //         Math.floor(item.x + (item.flipX ? sizeX : 0)), Math.floor(item.y),
        //         sizeX * (item.flipX ? -1 : 1), sizeY
        //     );
        // }

        g2.popTransformation();
        g2.popTransformation();
        g2.end();

        super.render(g2, false);

#if debug
        final time = Timer.stamp();
        final renderTime = time - renderStart;
        Debug.renderTimes.push(renderTime);
        Debug.renderTimes.shift();

        Debug.renderFrames.push(time);
        while (true) {
            if (Debug.renderFrames[0] != null && Debug.renderFrames[0] < time - 0.999) {
                Debug.renderFrames.shift();
            } else {
                break;
            }
        }
#end
    }

    function nextRoom (tied:Bool) {
        if (tied) {
            wins = 0;
            world.makeRoom(null, null);
            makeGenes();
            return;
        }
        final winningDna = world.room.actors.filter(a -> a.hp > 0)[0].dna;
        trace(winningDna.genes);
        if (winningDna == world.room.actors[0].dna) {
            wins++;
        } else {
            wins = 0;
        }
        world.makeRoom(winningDna, null);
        makeGenes();
    }

    function makeGenes () {
        genes1.genes = world.room.actors[0].dna.genes;
        genes2.genes = world.room.actors[1].dna.genes;
    }

    function handlePointer (delta:Float) {
        var text = '';

        Mouse.get().setSystemCursor(MouseCursor.Default);
        final screenPosX = camera.scrollX + Game.mouse.position.x / camera.scale;
        final screenPosY = camera.scrollY + Game.mouse.position.y / camera.scale;

        // tilePosAt = getTilePosAt(screenPosX, screenPosY, worldRotation, world.rooms[focusedRoom].grid.width, world.rooms[focusedRoom].grid.height);
#if debug
        devTexts[0].setText('${Game.mouse.position.x},${Game.mouse.position.y}, ${screenPosX},${screenPosY}');

        devTexts[1].setText('${tilePosAt.x},${tilePosAt.y}');
        // uiScene.setMiddleText('${camCenterX()} ${camCenterY()} ${minX} ${minY} ${maxX} ${maxY}', 1.0);
#end

        final clicked = Game.mouse.justPressed(0);

        selectedActor = null;
        for (ra in renderedActors) {
            if (pointInRect(screenPosX, screenPosY, ra.x, ra.y, 16, 32)) {
                selectedActor = ra.actor;
            }
        }

#if debug
        // TODO: bottom text
        devTexts[7].setText(text);
#end
    }

    function handleEvents (events:Array<RoomEvent>) {
        for (e in events) {
            if (e.type == ThingEnd) {
                particles.push({ tile: 176 + e.thingType, x: e.x, y: e.y, dir: e.dir, time: 30 });
            }
            if (e.type == Damage) {
                particles.push({ tile: -1, x: e.x, y: e.y, number: e.amount, time: 60, color: 0xffb4202a });
            }
        }
    }

    function updateParticles () {
        particles = particles.filter(p -> --p.time > 0);
    }

    // var numIndex = -1;
    // function makeNumber (x:Float, y:Float, amount:Int, green:Bool) {
    //     final num = numbers[(++numIndex % numbers.length)];
    //     num.show(x, y, green ? Green : Red);
    //     num.setText('$' + amount);
    // }

    inline function sendLogs () {
        final req = new haxe.Http('http://localhost:4000');
#if kha_html5
        req.async = true;
#end
        req.setPostData(getData());
        req.setHeader('Content-Type', 'application/json');
        req.onStatus = (num) -> {
            trace('status: ', num);
        };
        req.onError = (msg) -> {
            trace('error', msg);
        };
        req.request(true);
    }

    inline function getData ():String {
        return Json.stringify({
            gameId: gameId,
            seed: world.seed,
            commands: world.commands
        });
    }
}
