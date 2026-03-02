package game.world;

enum abstract ThingType(Int) {
    var TestType;
}

typedef ThingData = {
    var name:String;
}

typedef ThingId = Int;

// one or more pieces. an inanimate object.
class Thing {
    public static var curId:Int;

    // static vals
    public final id:ThingId;
    public var x:Int;
    public var y:Int;

    public var name:String;
    public var type:ThingType;

    public function new (type:ThingType, name:String, x:Int, y:Int) {
        id = curId++;

        this.type = type;
        this.name = name;
        this.x = x;
        this.y = y;
    }
}
