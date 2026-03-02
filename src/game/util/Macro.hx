package game.util;

import core.util.Util;

class Macro {
	public static macro function createDiffs(distance:Int) {
		final exprs:Array<haxe.macro.Expr> = [];
		for (x in 0...(distance * 2 + 1)) {
			for (y in 0...(distance * 2 + 1)) {
                if (distanceBetween(0, 0, x - distance, y - distance) < distance && !(x - distance == 0 && y - distance == 0)) {
                    exprs.push(macro new IntVec2($v{x - distance}, $v{y - distance}));
                }
			}
		}

		return macro [$a{exprs}];
	}
}
