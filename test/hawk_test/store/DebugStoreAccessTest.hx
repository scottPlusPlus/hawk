package hawk_test.store;

import hawk.store.LocalKVStore;
import hawk.testutils.TestVals;
import tink.core.Noise;
import hawk.store.DebugStoreAccess;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;

class DebugStoreAccessTest extends utest.Test {

	public function testHappy(async:utest.Async) {
		var name = "name";

		var store = new LocalKVStore();
		store.set(TestVals.key1, TestVals.val1);
		var direct = new DebugStoreAccess();
		direct.register(name, store);

		return direct.query("get", name, TestVals.key1).next(function(s:String) {
			Assert.equals(TestVals.val1, s);

			return direct.query("set", name, TestVals.key2, TestVals.val2);
		}).next(function(s:String) {
			Assert.equals(TestVals.val2, s);
			return Noise;
		}).closeTestChain(async);
	}

	public function testPrint(async:utest.Async) {

		var map = new Map<String,String>();
		map.set(TestVals.foo, TestVals.bar);
		map.set(TestVals.foo2, TestVals.bar2);

		var store = new LocalKVStore(map);
		var direct = new DebugStoreAccess();
		var name = "name";
		direct.register(name, store);
		return direct.query("print", name).next(function(s:String) {
			for (v in [TestVals.foo, TestVals.bar, TestVals.foo2, TestVals.bar2]){
				Assert.stringContains(v, s);
			}
			return Noise;
		}).closeTestChain(async);
	}
}
