package hawk_test.util;

import yaku_core.test_utils.TestVals;
import hawk.store.KVC;
import hawk.store.ArrayKV;
import zenlog.Log;
import yaku_core.PromiseX;
import hawk.util.Batcher;
import utest.Assert;
import tink.CoreApi;
import haxe.Constraints.IMap;

using yaku_core.test_utils.PromiseTestUtils;
using yaku_core.NullX;

class BatcherTest extends utest.Test {
	private var _fetchedWaves:Array<Array<String>>;
	private var _fetcherBegins:SignalTrigger<Noise>;
	private var _fetchedData:Map<String,String>;

	public function setup() {
		_fetchedWaves = [];
		_fetcherBegins = new SignalTrigger();
		_fetchedData = new Map();
		_fetchedData.set(TestVals.key1, TestVals.val1);
		_fetchedData.set(TestVals.key2, TestVals.val2);
		_fetchedData.set(TestVals.key3, TestVals.val3);
	}

	function testSimple(async:utest.Async) {
		var batcher = new Batcher(exampleFetcher, 50);

		var p1 = batcher.request(TestVals.key1).next(function(val) {
			Assert.equals(TestVals.val1, val);
			return Noise;
		}).eager();

		var p2 = batcher.request(TestVals.key2).next(function(val) {
			Assert.equals(TestVals.val2, val);
			return Noise;
		}).eager();

		Promise.inParallel([p1, p2]).next(function(_) {
			Assert.equals(1, _fetchedWaves.length);
			return Noise;
		}).closeTestChain(async);
	}


	@:timeout(500)
	function testBatches(async:utest.Async) {
		var batcher = new Batcher(exampleFetcher, 50);

		var p1 = batcher.request(TestVals.key1).next(function(val) {
			Assert.equals(TestVals.val1, val);
			return Noise;
		}).eager();

		var p2 = batcher.request(TestVals.key2).next(function(val) {
			Assert.equals(TestVals.val2, val);
			return Noise;
		}).eager();

		var p3 = PromiseX.waitPromise(60).next(function(_) {
			return batcher.request(TestVals.key3).next(function(val) {
				Assert.equals(TestVals.val3, val);
				return Noise;
			});
		}).eager();

		Promise.inParallel([p1, p2, p3]).next(function(_) {
			Assert.equals(2, _fetchedWaves.length);
			return Noise;
		}).closeTestChain(async);
	}

	function exampleFetcher(keys:Array<String>):Promise<ArrayKV<String, String>> {
		Log.debug('trigger fetch: ${keys}');
		_fetcherBegins.trigger(Noise);
		return PromiseX.waitPromise(100).next(function(_) {
			Log.debug('fetch complete for ${keys}');
			_fetchedWaves.push(keys);
			var res = new ArrayKV<String,String>();
			for (key in keys) {
				var val = _fetchedData.get(key).nullThrows();
				res.push(new KVC(key, val));
			}
			return res;
		});
	}
}
