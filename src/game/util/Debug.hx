package game.util;

#if debug
class Debug {
    public static var renderFrames:Array<Float> = []; // how many frames happened in the last second
    public static var renderTimes:Array<Float>; // list of all times it took to render (in seconds) (stays the same length)

    public static var updateFrames:Array<Float> = []; // how many update calls happened in the last second
    public static var updateTimes:Array<Float>; // list of all times it took to update (in seconds) (stays the same length)
}
#end