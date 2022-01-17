package hawk_test.store;

import yaku_core.test_utils.TestVals;
import hawk.store.IKVStore;
import hawk.store.LocalMemKVStoreFactory;
import utest.Assert;
import utest.Async;
import tink.CoreApi;

using yaku_core.test_utils.PromiseTestUtils;

class LocalKVStoreFactoryTest extends utest.Test {
	public function testLocalKVStoreFactory(async:utest.Async) {
		var factory = new LocalMemKVStoreFactory();
		var store:IKVStore<String, String>;
		var setup = function() {
			return factory.get("foo").next(function(res) {
				store = res;
				return Noise;
			});
		}

		var act = function(_) {
			return store.set(TestVals.key1, TestVals.val1);
		}

		return setup().next(act).next(function(_) {
			return store.get(TestVals.key1).next(function(actual) {
				Assert.equals(TestVals.val1, actual);
				return Noise;
			});
		}).closeTestChain(async);
	}
}
