package hawk_test.store;

import hawk.testutils.TestVals;
import hawk.store.IKVStore;
import hawk.store.LocalKVStoreFactory;
import utest.Assert;
import utest.Async;
import tink.CoreApi;

using hawk.testutils.PromiseTestUtils;

class LocalKVStoreFactoryTest extends utest.Test {
	public function testLocalKVStoreFactory(async:utest.Async) {
		var factory = new LocalKVStoreFactory();
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
