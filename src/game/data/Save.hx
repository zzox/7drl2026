package game.data;

import game.util.Player;
import kha.Storage;

final STORAGE_FILE = 'sons-test-save-data';

class Save {
    public static var settings:SaveSettings;

    public function new () {
        final obj = Storage.namedFile(STORAGE_FILE).readObject();
        if (obj == null) {
            settings = new SaveSettings();
        } else {
            settings = obj.settings;
        }
        Player.sfx = settings.sfx;
        Player.music = settings.music;
    }

    public static function writeSave () {
        Storage.namedFile(STORAGE_FILE).writeObject({ settings: settings });
    }
}

class SaveSettings {
    public var music:Bool = true;
    public var sfx:Bool = true;
    public var speed:Int = -1;

    public function new () {}
}
