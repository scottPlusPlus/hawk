package hawk_test.store;

import hawk.general_tools.adapters.SelfAdapter;
import hawk.testutils.TestLogger;
import zenlog.Log;
import tink.core.Noise;
import hawk.store.InMemoryKIntStore;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;

class InMemoryKIntStoreTest extends utest.Test {
	public function testSetAddGet(async:utest.Async) {
		//TestLogger.setDebug(true);
		Log.debug('testSetAddGet');
		var adapter = SelfAdapter.create();
		var store = new InMemoryKIntStore<String>(adapter);
		var key = "key";

		store.set(key, 0)
			.next(function(_) {
				return store.add(key, 2);
			})
			.next(function(v:Int) {
				Log.debug('adds 1');
				Assert.equals(2, v);
				return store.add(key, 3);
			})
			.next(function(v:Int) {
				Log.debug('adds 2');
				Assert.equals(5, v);
				return Noise;
			})
			.next(function(_) {
				return store.get(key);
			})
			.next(function(v:Int) {
				Log.debug('adds 5');
				Assert.equals(5, v);
				return Noise;
			}).closeTestChain(async);
	}
}
