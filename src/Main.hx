import core.Game;
import game.scenes.GameScene;
import game.scenes.HarnessScene;

#if kha_html5
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import kha.Macros;
#end

class Main {
    public static function main() {
        setFullWindowCanvas();
#if harness
        new Game(
            'br',
            1280, 720,
            PixelPerfect,
            new HarnessScene(),
            640, 360
        );
#else
        new Game(
            'br',
            1280, 720,
            PixelPerfect,
            new GameScene(),
            320, 180,
        );
#end

        // new Game(
        //     new IntVec2(1300, 750),
        //     new TestScene(),
        //     PixelPerfect,
        //     'boilerplate',
        //     new IntVec2(320, 180),
        //     (e) -> {
        //         sendErrorLogs(e);
        //         throw e;
        //     },
        //     (item:Dynamic) -> {
        //         if (item.type == 'sound' && StringTools.contains(item.files[0], 'random-string-here')) {
        //             return false;
        //         }
        //         return true;
        //     }
        // );
    }

    // This handles the resizing on our own so we don't rely on kha's.
    // Requires `kha_html5_disable_automatic_size_adjust` define.
    static function setFullWindowCanvas() {
        #if kha_html5
        document.documentElement.style.padding = '0';
        document.documentElement.style.margin = '0';
        document.body.style.padding = '0';
        document.body.style.margin = '0';
        final canvas:CanvasElement = cast document.getElementById(Macros.canvasId());
        canvas.style.display = 'block';
        canvas.style.imageRendering = 'pixelated';
        final resize = function() {
            var w = document.documentElement.clientWidth;
            var h = document.documentElement.clientHeight;
            if (w == 0 || h == 0) {
                w = window.innerWidth;
                h = window.innerHeight;
            }
            // WARN: can cause some weird issues with window.devicePixelRatio
            canvas.width = Std.int(w * window.devicePixelRatio);
            canvas.height = Std.int(h * window.devicePixelRatio);
            if (canvas.style.width == '') {
                canvas.style.width = '100%';
                canvas.style.height = '100%';
            }
        }
        window.onresize = resize;
        resize();
        #end
    }
}
