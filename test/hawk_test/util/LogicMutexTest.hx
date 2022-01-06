package hawk_test.util;

import tink.CoreApi;
import yaku_core.PromiseX;
import hawk.util.LogicMutex;
import utest.Assert;
import utest.Async;

class LogicMutexTest extends utest.Test {
	public function testMutex(async:utest.Async) {
		var res = new Array<String>();

		var mutex = new LogicMutex();

		var p1 = mutex.aquire().next(function(lock:Lock) {
			return PromiseX.waitPromise(100).next(function(_) {
				res.push("p1");
				lock.release();
				return Noise;
			});
		});

		var p2 = mutex.aquire().next(function(lock:Lock) {
			return PromiseX.waitPromise(50).next(function(_) {
				res.push("p2");
				lock.release();
				return Noise;
			});
		});

		Promise.inParallel([p1, p2]).next(function(_) {
			Assert.same(res, ["p1", "p2"]);
            async.done();
            return Noise;
		}).eager();
	}
}
