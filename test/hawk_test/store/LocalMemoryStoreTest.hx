package hawk_test.store;

import hawk.store.KVC;
import hawk.store.KVX;
import zenlog.Log;
import hawk.testutils.TestVals;
import tink.core.Noise;
import hawk.store.LocalMemoryStore;
import utest.Assert;
import utest.Async;

using hawk.store.IKVStoreX;
using hawk.testutils.PromiseTestUtils;

class LocalMemoryStoreTest extends utest.Test {
	public function testHappy(async:utest.Async) {
		var store = new LocalMemoryStore();
		var foo = "foo";
		var foo2 = "footwo";
		var bar = "bar";

		store.set(foo, bar)
			.next(function(v:String) {
				Assert.equals(bar, v);

				return store.exists(foo);
			})
			.next(function(v:Bool) {
				Assert.equals(true, v);

				return store.exists("asdf");
			})
			.next(function(v:Bool) {
				Assert.equals(false, v);

				return store.get("adsf");
			})
			.next(function(v:Null<String>) {
				Assert.equals(null, v);

				return store.get(foo);
			})
			.next(function(v:Null<String>) {
				Assert.equals(bar, v);

				return store.remove(foo);
			})
			.next(function(v:Bool) {
				Assert.equals(true, v);

				return store.exists(foo);
			})
			.next(function(v:Bool) {
				Assert.equals(false, v);

				return store.set(bar, foo);
			})
			.next(function(v:String) {
				Assert.equals(foo, v);

				return store.set(bar, foo2);
			})
			.next(function(v:String) {
				Assert.equals(foo2, v);

				return store.getOrErr(bar);
			})
			.next(function(v:String) {
				Assert.equals(foo2, v);
				return Noise;
			})
			.closeTestChain(async);
	}

	public function testGetMany(async:utest.Async) {
		var map = new Map<String, String>();

		map.set(TestVals.foo, TestVals.bar);
		map.set(TestVals.foo2, TestVals.bar2);
		map.set(TestVals.foo3, TestVals.bar3);

		var store = new LocalMemoryStore(map);

        var expected = [];
        expected.push(new KVC(TestVals.foo, TestVals.bar));
        expected.push(new KVC(TestVals.foo2, TestVals.bar2));
        expected.push(new KVC(TestVals.foo3, TestVals.bar3));

		store.getMany([TestVals.foo, TestVals.foo2, TestVals.foo3]).next(function(kvs) {
			kvs.sort(KVX.compareStringKeys);
			Assert.same(expected, kvs);
			return Noise;
		}).closeTestChain(async);
	}
}
