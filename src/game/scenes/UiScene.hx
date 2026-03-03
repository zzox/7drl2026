package game.scenes;

import core.Game;
import core.Types;
import core.gameobjects.BitmapText;
import core.gameobjects.NineSlice;
import core.gameobjects.Sprite;
import core.scene.Scene;
import core.util.Util;
import game.ui.AlertWindow;
import game.ui.ConfirmWindow;
import game.ui.UiButtons;
import game.ui.UiElement;
import game.ui.UiText;
import game.ui.UiWindow;
import game.util.Debug;
import game.util.TextUtil;
import game.world.World;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;

typedef TopButton = {
    var button:UiElement;
    var icon:Sprite;
}

class UiScene extends Scene {
    public static inline final WinTop:Int = 32;
    public static inline final DayTimeWidth:Int = 128;

    public static inline final Black:Int = 0x000000;
    public static inline final White:Int = 0xffffff;
    public static inline final Grey:Int = 0x5e606e;
    public static inline final LightGrey:Int = 0xb5b5b5;
    public static inline final Red:Int = 0xe23d69;
    public static inline final Green:Int = 0x6cd947;
    public static inline final Gold:Int = 0xffd93f;

    var gameScene:GameScene;
    var world:World;

    var dayText:BitmapText;
    var dateText:BitmapText;
    var timeText:BitmapText;
    var dollarText:BitmapText;
    var dollarBg:UiElement;

    var middleTextTime:Float = 0.0;
    var middleText:BitmapText;
    var middleSubtext:BitmapText;

    var topButtons:Array<TopButton> = [];
    var ffIcon:Sprite;
    public var ffSpeed:Int = 0;
    var windows:Array<UiWindow> = [];
    public var topWindows:Array<UiWindow> = [];
    public var hovered:Bool = false;
    public var buttonPressed:Bool = false;
    public var bringFront:Int = -1;
    // public var logWindow:LogWindow;

    var mouseX:Int;
    var mouseY:Int;
    var height:Int;
    var width:Int;

#if debug
    public var devTexts:Array<BitmapText> = [];
#end

    public function new (gameScene:GameScene, world:World) {
        super();
        this.gameScene = gameScene;
        this.world = world;
    }

    override function create () {
        super.create();
        // camera.scale = 2;

        final dayTimeBg = new NineSlice(0, 0, 16, 16, 4, 4, 12, 12, DayTimeWidth, WinTop, Assets.images.ui);
        dollarBg = new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 64, WinTop, 0, Assets.images.ui);

        dayTimeBg.tileIndex = 14;
        dollarBg.tileIndex = 14;

        entities.push(dayTimeBg);
        entities.push(dollarBg);
        entities.push(dayText = makeBitmapText(6, 4, '', UiScene.Black));
        entities.push(dateText = makeBitmapText(6, 4, '', UiScene.Black));
        entities.push(timeText = makeBitmapText(6, 14, '', UiScene.Black));
        entities.push(dollarText = makeBitmapText(camera.width, 9, '', UiScene.Black));
        entities.push(middleText = makeBitmapText(0, 64, ''));
        entities.push(middleSubtext = makeBitmapText(0, 80, ''));

        // makeTopButton(6, 4, launchRatingsWindow);

        ffIcon = makeTopButton(8, 3, changeFFSpeed);
        // makeTopButton(9, 6, gameScene.zoomOut);
        // makeTopButton(10, 7, gameScene.zoomIn);
        // makeTopButton(11, 8, gameScene.rotateLeft);
        // makeTopButton(12, 9, gameScene.rotateRight);

        // final logsButton = makeUiButton(dayTimeBg.elementSizeX, 0, 32, WinTop, 4, launchLogsWindow);
        // final statsButton = makeUiButton(dayTimeBg.elementSizeX + 32, 0, 32, WinTop, 4, launchStatsWindow);
        // entities.push(logsButton);
        // topButtons.push(logsButton);
        // entities.push(statsButton);
        // topButtons.push(statsButton);

        // entities.push(nineSlice = new NineSlice(0, 0, 16, 16, 3, 3, 13, 13, 250, 100, Assets.images.ui));
        // entities.push(el = new UiElement(0, 0, 16, 16, 3, 3, 13, 13, 250, 100, Assets.images.ui, () -> {
        //     ct++;
        // }));

        // final window = new TestWindow(0, 0);
        // windows.push(window);

        // final window2 = new TestWindow(16, 16);
        // windows.push(window2);

        // logWindow = new LogWindow(320, 100, logs);
        // statsWindow = new StatsWindow(240, WinTop, world);
        // leftPanel = new LeftPanel(0, WinTop, handleUpdateRoom);
        // windows.push(leftPanel);
        // windows.push(logWindow);
        // windows.push(statsWindow);

        // launchLogsWindow();

#if debug
        for (i in 0...8) {
            final text = makeBitmapText(DayTimeWidth + 4, 100 + i * 10, '');
            entities.push(text);
            devTexts.push(text);
            // text.visible = false;
        }
#end
    }

    override function update (delta:Float) {
        super.update(delta);

        final rightEdge = Math.max(Math.round(camera.width / camera.scale), 636);
        final bottomEdge = Math.max(Math.round(camera.height / camera.scale), 256);

        // dateText.setText('Day ${world.day + 1}');
        dateText.setPosition(DayTimeWidth - dateText.textWidth - 8, dateText.y);
        // timeText.setText(world.time + '');

        // dollarText.setText(TextUtil.formatMoney(world.money));
        // dollarText.setPosition(Math.floor(rightEdge - dollarText.textWidth - 8), dollarText.y);
        dollarBg.setPosition(rightEdge - dollarBg.elementSizeX, 0);
        // leftPanel.panel.elementSizeY = Math.floor(bottomEdge - WinTop);

        middleTextTime -= delta;
        middleText.setPosition(Math.floor((camera.width / camera.scale - middleText.textWidth) / 2), middleText.y);
        middleText.visible = middleTextTime > 0;

        // get mouse computed positions
        mouseX = Math.floor(Game.mouse.position.x / camera.scale);
        mouseY = Math.floor(Game.mouse.position.y / camera.scale);

        width = Math.round(game.width / camera.scale);
        height = Math.round(game.height / camera.scale);

        // update windows
        hovered = false;
        buttonPressed = false;

        // check top buttons first
        for (b in topButtons) {
            b.button.checkPointer(mouseX, mouseY);
            if (!b.button.disabled && b.button.onClick != null) {
                b.button.setIndexFromState();
                if (b.button.hovered) {
                    hovered = true;
                    Mouse.get().setSystemCursor(MouseCursor.Pointer);
                }
                if (b.button.pressed) {
                    buttonPressed = true;
                    Mouse.get().setSystemCursor(MouseCursor.Pointer);
                }
            }

            // mark if we hovered over any of these or if an item was pressed
            if (b.button.pressed) {
                hovered = true;
            }
        }
        if (!hovered) {
            dollarBg.checkPointer(mouseX, mouseY);
            if (dollarBg.hovered) {
                hovered = true;
                Mouse.get().setSystemCursor(MouseCursor.Pointer);
            }
        }

        // WARN: reuse of this var
        bringFront = topWindows.length;

        for (i in 0...topWindows.length) {
            final win = topWindows[i];
            if (!hovered) {
                checkWindow(win, i);
            } else {
                for (c in win.children) {
                    if (!c.el.disabled) {
                        c.el.hovered = false;
                        c.el.setIndexFromState();
                    }
                }
            }

            if (win.grabbable != null && win.flashTime < 0.0) {
                win.grabbable.tileIndex = i == windows.length - 1 ? 12 : 13;
            }

            win.update(delta);
        }

        if (topWindows.length > 0 && Game.mouse.justPressed(0) && !hovered) {
            // SOUND: alert
            topWindows[0].flashTime = 2.0;
        }

        topWindows = topWindows.filter(w -> !w.closed);

        bringFront = windows.length;
        var w = windows.length;
        // cursor is handled in GameScene#handlePointer
        // Mouse.get().setSystemCursor(MouseCursor.Default);
        while (--w >= 0) {
            final win = windows[w];

            // if we are over any of these ui elements, we can't do anything to the next element under us
            // or if we are dealing with a confirmWindow
            if (!hovered && topWindows.length == 0) {
                checkWindow(win, w);
            } else {
                // TODO: unhover the rest of the buttons of the screens under if we are hovered
                for (c in win.children) {
                    if (!c.el.disabled) {
                        c.el.hovered = false;
                        c.el.setIndexFromState();
                    }
                }
            }

            if (win.grabbable != null) {
                win.grabbable.tileIndex = w == windows.length - 1 ? 12 : 13;
            }

            win.update(delta);
        }

        // if we need to move around items, do so here
        if (bringFront < windows.length - 1) {
            bringToFront(bringFront);
        }

        windows = windows.filter(w -> !w.closed);

#if debug
        devTexts[2].setText('FPS: ${Debug.renderFrames.length}, avg: ${Math.round(average(Debug.renderTimes) * 1000)}ms');
        devTexts[3].setText('UPS: ${Debug.updateFrames.length}, avg: ${Math.round(average(Debug.updateTimes) * 1000)}ms');

        // pathfinds averages (is this correct?)
        // Debug.pathfinds.slice(-100);
        // final pfTotals = Lambda.fold(Debug.pathfinds, (item, res) -> {
        //     return [item[0] + res[0], item[1] + res[1], item[2] + res[2]];
        // }, [0, 0, 0]);
        // pfTotals[0] = Math.round(nanZero(pfTotals[0] / Debug.pathfinds.length));
        // pfTotals[1] = Math.round(nanZero(pfTotals[1] / Debug.pathfinds.length));
        // pfTotals[2] = Math.round(nanZero(pfTotals[2] / Debug.pathfinds.length));
        // devTexts[4].setText('iter:${pfTotals[0]} len:${pfTotals[1]} ${pfTotals[2]}us, last: ${Debug.pathfinds[Debug.pathfinds.length - 1]}');
        
        // @:privateAccess
        // devTexts[5].setText('payroll: O:${world.payroll.owedActors.length} S:${world.payroll.sortedActors.length}');
        devTexts[5].setText('Comm:${world.commands.length}');

        // devTexts[6].setText('C:${world.room?.actors.length}');
#end
    }

    override function render (g2:Graphics, clears:Bool) {
        g2.begin(clears, camera.bgColor);

        for (e in entities) {
            if (e.visible) e.render(g2, camera);
        }
        for (w in windows) w.render(g2, camera);
        for (t in topWindows) t.render(g2, camera);

// #if debug_physics
//         for (sprite in entities) {
//             sprite.renderDebug(g2, camera);
//         }
// #end
        g2.end();
    }

    inline function checkWindow (win:UiWindow, index:Int) {
        for (c in win.children) {
            // for every button update state and set the tile index if it has a onclick,
            // we assume it is a button.
            if (!c.el.disabled && c.el.visible) {
                c.el.checkPointer(mouseX, mouseY);
                if (c.el.onClick != null) {
                    c.el.setIndexFromState();
                    if (c.el.hovered) {
                        Mouse.get().setSystemCursor(MouseCursor.Pointer);
                    }
                    if (c.el.pressed) {
                        buttonPressed = true;
                        Mouse.get().setSystemCursor(MouseCursor.Pointer);
                    }
                }
            } else if (c.el.disabled) {
                c.el.setIndexFromState();
            }

            // if we're over the grabbable item (and we aren't pressing a button)
            if (c.el == win.grabbable && c.el.hovered && !buttonPressed) {
                Mouse.get().setSystemCursor(MouseCursor.Grab);
                if (Game.mouse.justPressed(0)) {
                    win.heldPos = new IntVec2(Math.floor(mouseX - win.x), Math.floor(mouseY - win.y));
                }
            }

            // mark if we hovered over any of these or if an item was pressed
            if (c.el.hovered || c.el.pressed) {
                hovered = true;
            }

            if (c.el.hovered && c.el.pressed) {
                bringFront = index;
            }
        }

        if (win.heldPos != null) {
            // unset if we are also pressing a button
            if (buttonPressed) {
                win.heldPos = null;
            } else {
                // win.y = mouseY - win.heldPos.y;
                win.x = Std.int(clamp(mouseX - win.heldPos.x, DayTimeWidth, width - win.width));
                win.y = Std.int(clamp(mouseY - win.heldPos.y, WinTop, height - win.height));
                if (Game.mouse.justReleased(0)) {
                    win.heldPos = null;
                }
                Mouse.get().setSystemCursor(MouseCursor.Grabbing);
            }
        }
    }

    public function setMiddleText (text:String, time:Float) {
        middleText.setText(text);
        middleTextTime = time;
    }
    function bringToFront (bfIndex:Int) {
        final newTop = windows[bfIndex];
        windows.remove(newTop);
        windows.push(newTop);
    }

    public function windowsContains (name:String, onTop:Bool = true):Bool {
        var w = windows.length;
        while (--w > 0) {
            if (onTop) {
                return windows[w].name == name;
            }

            if (windows[w].name == name) {
                return true;
            }
        }

        return false;
    }

    // public function launchAlertWindow (headerText:String, subText:String) {
    //     // logWindow = new LogWindow(320, 100, logs);
    //     windows.push(new AlertWindow(headerText, subText));
    // }

    public function launchConfirmWindow (headerText:String, subText:String, callback:Void -> Void) {
        // logWindow = new LogWindow(320, 100, logs);
        final width = getViewportWidth();
        final height = getViewportHeight();

        final window = new ConfirmWindow(
            Math.floor(DayTimeWidth + (width - ConfirmWindow.Width) / 2),
            Math.floor(WinTop + (height - ConfirmWindow.Height) / 2),
            headerText, subText, callback
        );

        topWindows.push(window);
    }

    public function launchAlertWindow (headerText:String, subText:String) {
        // logWindow = new LogWindow(320, 100, logs);
        final width = getViewportWidth();
        final height = getViewportHeight();

        final window = new AlertWindow(0, 0, headerText, subText);

        window.x = Math.floor(DayTimeWidth + (width - window.width) / 2);
        window.y = Math.floor(WinTop + (height - window.height) / 2);

        topWindows.push(window);
    }

    public function bringFrontWindowExists (name:String):Bool {
        for (i in 0...windows.length) {
            if (windows[i].name == name) {
                bringToFront(i);
                return true;
            }
        }

        return false;
    }

    function changeFFSpeed () {
        ffSpeed = (ffSpeed + 1) % 3;
        ffIcon.tileIndex = 51 + ffSpeed;
    }

    function makeTopButton (pos:Int, imgIndex:Int, cb:Void -> Void):Sprite {
        final button = makeUiButton(DayTimeWidth + pos * 32, 0, 32, WinTop, 0, cb);
        final icon = new Sprite(DayTimeWidth + pos * 32, 0, Assets.images.ui, 32, 32);
        icon.tileIndex = imgIndex + 48;
        entities.push(button);
        entities.push(icon);
        topButtons.push({ button: button, icon: icon });
        return icon;
    }

    inline function getViewportWidth () {
        return (camera.width - (camera.scale * DayTimeWidth)) / camera.scale;
    }

    inline function getViewportHeight () {
        return (camera.height - (camera.scale * WinTop)) / camera.scale;
    }
}
