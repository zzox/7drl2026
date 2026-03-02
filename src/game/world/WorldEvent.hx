package game.world;

enum EventType {
    Arrive;
    Leave;
}

typedef Event = {
    var type:EventType;
    var actor:Actor;
    var ?thing:Thing;
    var ?amount:Int;
}
