package test.hawk.util;

import tink.core.Noise;
import tink.core.Future;
import tink.core.Future.FutureTrigger;
import utest.Assert;
import hawk.util.FutureX;

using hawk.util.FutureX;

class FutureXTest extends utest.Test {
	function testWait() {
		var f = FutureX.wait(100);
		Assert.notNull(f);
	}

	function testThens() {
		var fut1 = new FutureTrigger<Int>();

		var doubleFunc = function(val:Int):Future<Int> {
			var res = new FutureTrigger<Int>();
			res.trigger(val * 2);
			return res.asFuture();
		}

		var incrementFunc = function(val:Int):Future<Int> {
			var res = new FutureTrigger<Int>();
			res.trigger(val + 1);
			return res.asFuture();
		}

		var actual:Int = 0;
		var setFunc = function(val:Int):Future<Noise> {
			var res = new FutureTrigger<Noise>();
			actual = val;
			res.trigger(Noise);
			return res;
		}

		var foobar = fut1.asFuture().then(doubleFunc).then(incrementFunc).then(setFunc);

		Assert.equals(0, actual);

		fut1.trigger(5);
		Assert.equals(11, actual);
	}

	function testVoidNoise() {

		var actual = 0;

		var incrementActual = function(_):Future<Noise> {
			actual ++;
			return FutureX.resolvedFuture(Noise);
		}

		var doubleActual = function(_):Future<Noise> {
			actual = actual *2; 
			return FutureX.resolvedFuture(Noise);
		}

		var fut1 = new FutureTrigger<Noise>();
		fut1.then(incrementActual).then(doubleActual);

		fut1.trigger(Noise);
		Assert.equals(2, actual);
	}
}
