package hawk_test.store;

import tink.core.Noise;
import hawk.store.DebugStoreAccess;
import hawk.store.LocalMemoryStore;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;

class DebugStoreAccessTest extends utest.Test {

	public function testHappy(async:utest.Async) {
		var myKey = "foo";
		var myKey2 = "foo2";
		var myVal = "bar";
		var myVal2 = "bar2";
		var name = "name";

		var store = new LocalMemoryStore();
		store.set(myKey, myVal);
		var direct = new DebugStoreAccess();
		direct.register(name, store);

		return direct.query("get", name, myKey).next(function(s:String) {
			Assert.equals(myVal, s);

			return direct.query("set", name, myKey2, myVal2);
		}).next(function(s:String) {
			Assert.equals(myVal2, s);
			return Noise;
		}).closeTestChain(async);
	}
}
