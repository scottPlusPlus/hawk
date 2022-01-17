package hawk_test.util;

import hawk.store.KVC;
import hawk.store.ArrayKV;
import zenlog.Log;
import yaku_core.PromiseX;
import hawk.util.Batcher;
import utest.Assert;
import tink.CoreApi;
import haxe.Constraints.IMap;

using yaku_core.test_utils.PromiseTestUtils;

class BatcherTest extends utest.Test {
	private var _fetchedWaves:Array<Array<Int>>;
	private var _fetcherBegins:SignalTrigger<Noise>;

	public function setup() {
		_fetchedWaves = [];
		_fetcherBegins = new SignalTrigger();
	}

	function testSimple(async:utest.Async) {
		var batcher = Batcher.createIntBatcher(exampleFetcher, 50);

		var p1 = batcher.request(2).next(function(val) {
			Assert.equals(4, val);
			return Noise;
		}).eager();

		var p2 = batcher.request(3).next(function(val) {
			Assert.equals(6, val);
			return Noise;
		}).eager();

		Promise.inParallel([p1, p2]).next(function(_) {
			Assert.equals(1, _fetchedWaves.length);
			return Noise;
		}).closeTestChain(async);
	}

	function testNullable(async:utest.Async) {
		var batcher = Batcher.createIntBatcher(exampleFetcher, 50);

		var p1 = batcher.request(1).next(function(val) {
			Assert.equals(2, val);
			return Noise;
		}).eager();

		var p2 = batcher.request(-1).next(function(val) {
			Assert.isNull(val);
			return Noise;
		}).eager();

		Promise.inParallel([p1, p2]).closeTestChain(async);
	}

	@:timeout(500)
	function testBatches(async:utest.Async) {
		var batcher = Batcher.createIntBatcher(exampleFetcher, 50);

		var p1 = batcher.request(1).next(function(val) {
			Assert.equals(2, val);
			return Noise;
		}).eager();

		var p2 = batcher.request(-1).next(function(val) {
			Assert.isNull(val);
			return Noise;
		}).eager();

		var p3 = PromiseX.waitPromise(60).next(function(_) {
			return batcher.request(3).next(function(val) {
				Assert.equals(6, val);
				return Noise;
			});
		}).eager();

		Promise.inParallel([p1, p2, p3]).next(function(_) {
			Assert.equals(2, _fetchedWaves.length);
			return Noise;
		}).closeTestChain(async);
	}

	function exampleFetcher(keys:Array<Int>):Promise<ArrayKV<Int, Int>> {
		Log.debug('trigger fetch: ${keys}');
		_fetcherBegins.trigger(Noise);
		return PromiseX.waitPromise(100).next(function(_) {
			Log.debug('fetch complete for ${keys}');
			_fetchedWaves.push(keys);
			var res = new ArrayKV<Int,Int>();
			for (key in keys) {
				if (key > 0) {
					res.push(new KVC(key, key * 2));
				}
			}
			return res;
		});
	}
}
