package game.util;

import core.util.BitmapFont;
import game.world.Actor.ActorState;

class TextUtil {
    // format the text into correct line widths
    public static inline function formatText (string:String, width:Int, font:BitmapFont):Array<String> {
        final words = string.split(' ');

        var result = [];
        var current = '';
        for (w in words) {
            if (font.getTextWidth('$current $w') > width) {
                result.push(current);
                current = '';
            }

            if (current == '') {
                current = w;
            } else {
                current += ' $w';
            }
        }

        if (current != '') {
            result.push(current);
        }

        return result;
    }

    public static inline function formatMoney (amount:Int) {
        final amountString = amount + '';
        var result = '';
        var index = -1;
        while (++index < amountString.length) {
            result += amountString.charAt(index);
            if ((amountString.length - index - 1) % 3 == 0 && index != amountString.length - 1) {
                result += ',';
            }
        }

        return '$' + result;
    }

    public static inline function formatDay (day:Int):String {
        return 'Day ${day + 1}';
    }

    public static inline function formatDaysPassed (days:Int):String {
        return if (days < 7) {
            '${days}d';
        } else if (days < 28) {
            '${Math.floor(days / 7)}wk';
        } else if (days < 365) {
            '${Math.floor(days / 30)}mo';
        } else {
            '${Math.floor(days / 365)}yr';
        }
    }

    public static inline function padTime (int:Int):String {
        if (int < 10) {
            return '0${int}';
        }

        return '' + int; 
    }

    public static inline function formatActorState (state:ActorState):String {
        return switch (state:ActorState) {
            case None: '';
            case _: 'no';
        }
    }
}
