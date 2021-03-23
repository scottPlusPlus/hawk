package hawk_test.store;

import hawk.general_tools.adapters.SelfAdapter;
import zenlog.Log;
import tink.core.Noise;
import hawk.store.InMemoryKIntStore;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;

class InMemoryKIntStoreTest extends utest.Test {
	public function testSetAddGet(async:utest.Async) {
		var adapter = SelfAdapter.create();
		var store = new InMemoryKIntStore<String>(adapter);
		var key = "key";

		store.set(key, 0)
			.next(function(_) {
				return store.add(key, 2);
			})
			.next(function(v:Int) {
				Assert.equals(2, v);
				return store.add(key, 3);
			})
			.next(function(v:Int) {
				Assert.equals(5, v);
				return Noise;
			})
			.next(function(_) {
				return store.get(key);
			})
			.next(function(v:Int) {
				Assert.equals(5, v);
				return Noise;
			}).closeTestChain(async);
	}
}
