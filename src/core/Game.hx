package core;

import core.scene.PreloadScene;
import core.scene.Scene;
import core.system.Camera;
import core.system.KeysInput;
import core.system.MouseInput;
import core.util.ScalerExp;
import kha.Assets;
import kha.Framebuffer;
import kha.Image;
import kha.Scheduler;
import kha.ScreenCanvas;
import kha.System;
import kha.input.Keyboard;
import kha.input.Mouse;

enum ScaleMode {
    Full;
    PixelPerfect;
}

class Game {
    static inline final UPDATE_TIME:Float = 1 / 60;

    // time since start, set by the scheduler
    var currentTime:Float;

    // Size of the game.
    public var width:Int;
    public var height:Int;

    var scaleMode:ScaleMode;

    // Size of the buffer.
    public var bufferWidth:Int;
    public var bufferHeight:Int;

    // The backbuffer being drawn on to be scaled.  Not used in scaleMode `Fit`.
    var backbuffer:Image;

    // array of scenes about to become scenes
    var newScenes:Array<Scene> = [];
    // array of scenes to update and render
    var scenes:Array<Scene> = [];

    // Keyboard input controller.
    public static var keys:KeysInput = new KeysInput();

    public static var mouse:MouseInput = new MouseInput();

    public function new (name:String, width:Int, height:Int, scaleMode:ScaleMode, initialScene:Scene, ?bufferWidth:Int, ?bufferHeight:Int) {
        // size = IntVec2.make(width, height)
        this.width = width;
        this.height = height;

        System.start({ title: name, width: width, height: height }, (_window) -> {
            if (scaleMode == PixelPerfect) {
                if (bufferWidth == null || bufferHeight == null) {
                    throw 'Need buffer size';
                }

                backbuffer = Image.createRenderTarget(bufferWidth, bufferHeight);
                // backbuffer.g2.imageScaleQuality = Low;
                this.bufferWidth = bufferWidth;
                this.bufferHeight = bufferHeight;
            } else {
                this.bufferWidth = -1;
                this.bufferHeight = -1;
            }

            if (Keyboard.get() != null) {
                Keyboard.get().notify(keys.pressButton, keys.releaseButton);
            }

            if (Mouse.get() != null) {
                if (scaleMode == PixelPerfect) {
                    Mouse.get().notify(mouse.pressMouse, mouse.releaseMouse, onMouseMove);
                } else {
                    Mouse.get().notify(mouse.pressMouse, mouse.releaseMouse, mouse.mouseMove);
                }
            }

            Assets.loadEverything(() -> {
                Scheduler.addTimeTask(update, 0, UPDATE_TIME);

                if (scaleMode == PixelPerfect) {
                    System.notifyOnFrames((frames) -> { renderPixelPerfect(frames[0]); });
                } else {
                    System.notifyOnFrames((frames) -> { render(frames[0]); });
                }

                final preloadScene = new PreloadScene();
                addScene(preloadScene);

                // WARN: these can run out of order if there's nothing being loaded!
                // (Game will get stuck on Preload screen)
                Assets.loadEverything(() -> {
                    // HACK: force destroy preload scene to address above warning
                    preloadScene.destroy();
                    changeScene(initialScene);
                });
            }, (item) -> {
                // TODO: add any other preload sprites
                if (item.name == 'made_with_kha') return true;
                return false;
            });
        });
    }

    function update () {
        final now = Scheduler.time();

#if atomic
        final delta = now - currentTime;
#else
        final delta = UPDATE_TIME;
#end

        scenes = scenes.filter((s) -> !s.destroyed);

        for (s in newScenes) scenes.push(s);
        newScenes.resize(0);

        for (s in scenes) {
            // if (!s.isPaused) {
                s.update(delta);
            // }
        }

        // after the scenes to clear `justPressed`
        keys.update(UPDATE_TIME);
        mouse.update(UPDATE_TIME);

        currentTime = now;
    }

    function onMouseMove (x:Int, y:Int, moveX:Int, moveY:Int) {
        // NOTE: pass in scaling when there is zoom?
        mouse.mouseMove(
            ScalerExp.transformPixelPerfectX(x, backbuffer, ScreenCanvas.the),
            ScalerExp.transformPixelPerfectY(y, backbuffer, ScreenCanvas.the),
            ScalerExp.transformPixelPerfectX(x, backbuffer, ScreenCanvas.the),
            ScalerExp.transformPixelPerfectY(y, backbuffer, ScreenCanvas.the)
        );
    }

    // function update () {
    //     final now = Scheduler.time();
    //     final delta = now - currentTime;

    //     // update mouse for camera position
    //     final camExists = scenes[0] != null;
    //     mouse.setMousePos(
    //         Std.int(
    //             (camExists ? scenes[0].camera.scroll.x : 0) + mouse.screenPos.x /
    //             (camExists ? scenes[0].camera.scale.x : 0)
    //         ),
    //         Std.int(
    //             (camExists ? scenes[0].camera.scroll.y : 0) + mouse.screenPos.y /
    //             (camExists ? scenes[0].camera.scale.y : 0)
    //         )
    //     );

    //     for (s in newScenes) scenes.push(s);
    //     newScenes = [];
    //     for (s in scenes) {
    //         if (!s.isPaused) {
    //             s.updateProgress(Assets.progress);
    //             s.update(UPDATE_TIME);
    //         }

    //         // resize the camera if we use the `Full` scale mode.
    //         if (scaleMode == Full) {
    //             s.camera.width = size.x;
    //             s.camera.height = size.y;
    //         }
    //     }
    //     scenes = scenes.filter((s) -> !s._destroyed);

    //     // after the scenes to clear `justPressed`
    //     keys.update(UPDATE_TIME);
    //     mouse.update(UPDATE_TIME);
    //     surface.update(UPDATE_TIME);
    //     for (g in gamepads.list) {
    //         g.update(UPDATE_TIME);
    //     }

    //     currentTime = now;
    // }

    function render (framebuffer:Framebuffer) {
        setSize(framebuffer.width, framebuffer.height);

        for (s in 0...scenes.length) {
            // resize the camera if we use the `Full` scale mode.
            scenes[s].camera.width = width;
            scenes[s].camera.height = height;
            scenes[s].render(framebuffer.g2, /* framebuffer.g4 */ s == 0);
        }
    }

    function renderPixelPerfect (framebuffer:Framebuffer) {
        setSize(framebuffer.width, framebuffer.height);

        for (s in 0...scenes.length) {
            // scenes[s].render(backbuffer.g2, backbuffer.g4, s == 0);
            scenes[s].render(backbuffer.g2, s == 0);
        }

        framebuffer.g2.begin(true, 0xff000000);
            // framebuffer.g2.pipeline = fullScreenPipeline;
            ScalerExp.scalePixelPerfect(backbuffer, framebuffer);
        framebuffer.g2.end();
    }

    public function changeScene (scene:Scene, ?callback:Void -> Void) {
        for (s in scenes) s.destroy();
        // scenes = [];

        addScene(scene);

        if (callback != null) {
            callback();
        }
    }

    public function removeScene (scene:Scene) {
        scene.destroy();
    }

    public function addScene (scene:Scene) {
        newScenes.push(scene);
        scene.game = this;
        scene.camera = new Camera(bufferWidth > -1 ? bufferWidth : width, bufferHeight > -1 ? bufferHeight : height);
        scene.create();
    }

    inline function setSize (x:Int, y:Int) {
        width = x;
        height = y;
    }
}

// class OldGame {
//     public function new (
//         size:IntVec2,
//         initalScene:Scene,
//         scaleMode:ScaleMode = None,
//         name:String,
//         ?initialSize:IntVec2,
//         ?exceptionHandler:Exception -> Void,
//         ?compressedAudioFilter:Dynamic -> Bool
//     ) {
//         this.scaleMode = scaleMode;
//         this.size = size;

//         if (exceptionHandler == null) {
//             exceptionHandler = (e:Exception) -> throw e;
//         }

//         System.start({ title: name, width: size.x, height: size.y }, (_window) -> {
//             bufferSize = initialSize != null ? initialSize : size;
//             if (scaleMode != Full) {
//                 backbuffer = Image.createRenderTarget(bufferSize.x, bufferSize.y);
//                 backbuffer.g2.imageScaleQuality = Low;
//             }

//             // just the movement is PP or None, not `Full`
//             if (scaleMode == Full) {
//                 Mouse.get().notify(mouse.pressMouse, mouse.releaseMouse, mouse.mouseMove);
//                 Surface.get().notify(surface.press, surface.release, surface.move);
//             } else {
//                 // need to handle screen position and screen scale
//                 Mouse.get().notify(mouse.pressMouse, mouse.releaseMouse, onMouseMove);
//                 Surface.get().notify(surface.press, surface.release, onSurfaceMove);
//             }

//             // for WEGO
//             // Mouse.get().hideSystemCursor();

//             if (Keyboard.get() != null) {
//                 Keyboard.get().notify(keys.pressButton, keys.releaseButton);
//             }

//             for (i in 0...8) {
//                 if (Gamepad.get(i) != null && Gamepad.get(i).connected) {
//                     gamepadConnect(i);
//                 }
//             }

//             Gamepad.notifyOnConnect(gamepadConnect, gamepadDisconnect);

//             // Gamepad.removeConnect()

//             setFullscreenShader(makeBasePipelineShader());
//             setBackbufferShader(makeBasePipelineShader());

//             Assets.loadImage('made_with_kha', (_:Image) -> {
//                 switchScene(new PreloadScene());

//                 // HACK: run `update()` once to get preload scene from `newScenes` to `scenes`.
//                 // This kicks off the game.
//                 try { update(); } catch (e) { exceptionHandler(e); }

//                 Scheduler.addTimeTask(
//                     () -> {
//                         try { update(); } catch (e) { exceptionHandler(e); }
//                     },
//                     0,
//                     UPDATE_TIME
//                 );

//                 if (scaleMode == Full) {
//                     System.notifyOnFrames((frames) -> {
//                         try { render(frames[0]); } catch (e) { exceptionHandler(e); }
//                     });
//                 } else {
//                     System.notifyOnFrames(
//                         (frames) -> {
//                             try { renderScaled(frames[0]); } catch (e) { exceptionHandler(e); }
//                         }
//                     );
//                 }

//                 function allAssets (_:Dynamic) return true;

//                 Assets.loadEverything(() -> {
//                     switchScene(initalScene);
//                 }, null, compressedAudioFilter != null ? compressedAudioFilter : allAssets);
//             });
//         });
//     }
// }
