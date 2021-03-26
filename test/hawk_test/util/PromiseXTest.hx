package hawk_test.util;

import tink.CoreApi;
import utest.Assert;
import hawk.util.FutureX;

using hawk.testutils.PromiseTestUtils;
using hawk.util.PromiseX;
using hawk.util.OutcomeX;

class PromiseXTest extends utest.Test {
	public function testRecoverWithOnFailure(async:utest.Async) {
		var pt = new PromiseTrigger<Int>();
		pt.reject(new Error('a wild err appeared!'));
		pt.asPromise().recoverWith(5).next(function(v) {
			Assert.equals(5, v);
			return Noise;
		}).closeTestChain(async);
	}

	public function testRecoverWithOnSuccess(async:utest.Async) {
		var pt = new PromiseTrigger<Int>();
		pt.resolve(11);
		pt.asPromise().recoverWith(5).next(function(v) {
			Assert.equals(11, v);
			return Noise;
		}).closeTestChain(async);
	}

	public function testResultSuccess() {
		var pt = new PromiseTrigger<Int>();
		var res = pt.asPromise();
		pt.resolve(123);
		var actual = res.result().sure();
		Assert.equals(123, actual);
	}

	public function testResultError() {
		var pt = new PromiseTrigger<Int>();
		var res = pt.asPromise();
		var err = new Error('some error');
		pt.reject(err);
		var actual = res.result().failure();
		Assert.equals(err, actual);
	}

	public function testResultPremature() {
		var pt = new PromiseTrigger<Int>();
		var res = pt.asPromise();
		Assert.isTrue(res.result().isFailure());
	}

	public function testPushTo(async:utest.Async) {
		var all = new Array<Promise<Int>>();
		var p1 = eventualInt(1, 10).pushTo(all);
		var p2 = eventualInt(2, 20).pushTo(all);
		var p3 = eventualInt(3, 30).pushTo(all);

		return Promise.inParallel(all).next(function(_) {
			Assert.equals(1, p1.result().sure());
			Assert.equals(2, p2.result().sure());
			Assert.equals(3, p3.result().sure());
			return Noise;
		}).closeTestChain(async);
	}

	private function eventualInt(val:Int, delayMS:UInt):Promise<Int> {
		return PromiseX.waitPromise(delayMS).next(function(_) {
			return val;
		});
	}

	public function testTry(async:utest.Async) {
		var errmsg = 'trow in a promise';
		PromiseX.tryOrErr(function():Promise<Noise>{
			throw(errmsg);
			return Noise;
		}).mapError(function(err){
			Assert.stringContains(errmsg, err.message);
			Assert.pass('expected an error here');
			return err;
		}).recoverWith(Noise).closeTestChain(async);
	}

	public function testTimeoutFailure(async:utest.Async) {
		PromiseX.waitPromise(50).withTimeout(10).eager().handle(function(o){
			switch(o){
				case Success(data):
					Assert.fail('expected timeout failure');
				case Failure(failure):
					Assert.stringContains('timed out', failure.message);
					Assert.pass('expected an err here');
			}
			async.done();
		});
	}

	public function testTimeoutSuccess(async:utest.Async) {
		PromiseX.waitPromise(10).withTimeout(50).eager().handle(function(o){
			switch(o){
				case Success(data):
					Assert.pass('expected path');
				case Failure(failure):
					Assert.pass('expected success, got err: ${failure.message}');
			}
			async.done();
		});
	}
}
