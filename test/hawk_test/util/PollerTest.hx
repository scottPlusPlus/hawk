package hawk_test.util;

import haxe.Timer;
import tink.CoreApi;
import hawk.util.Poller;
import utest.Assert;
import utest.Async;

class PollerTest extends utest.Test {
	@:timeout(2000)
	function testPasses(async:utest.Async) {
		var gate = false;
		var checkCount = 0;

		var check = function() {
			checkCount++;
			return Promise.resolve(gate);
		}

		var start = Timer.stamp();

		var p = Poller.waitUntil(check);
		haxe.Timer.delay(function() {
			gate = true;
		}, 1000);

		p.flatMap(function(o:Outcome<Noise, Error>) {
			Assert.isTrue(o.isSuccess());
			Assert.isTrue(checkCount >= 9 && checkCount <= 10);

			var dur = Timer.stamp() - start;
			Assert.isTrue(dur < 1.2);
			async.done();
			return Noise;
		}).eager();
	}

	@:timeout(2000)
	function testTimeoutReturnsError(async:utest.Async) {
		var gate = false;
		var checkCount = 0;

		var check = function() {
			checkCount++;
			return Promise.resolve(gate);
		}

		var start = Timer.stamp();

		var p = Poller.waitUntil(check, 100, 500);

		p.flatMap(function(o:Outcome<Noise, Error>) {
			Assert.isFalse(o.isSuccess());
			Assert.equals(5, checkCount);
			var dur = Timer.stamp() - start;
			Assert.isTrue(dur < 0.7);
			async.done();
			return Noise;
		}).eager();
	}
}
