package game.data;

import game.world.WorldEvent;

typedef LogData = {
    var type:EventType;
    var name:String;
    var time:Int;
    var day:Int;
}

class Logs {
    public function new () {}
    public final items:Array<LogData> = [];
}
