package hawk_test.store;

import hawk.store.LocalMemKVStore;
import hawk.async_iterator.AsyncIteratorX;
import tink.CoreApi;
import hawk.store.KV;
import hawk.store.KVC;
import hawk.store.KVX;
import hawk.store.IKVStore;
import hawk.store.KVStoreAdapter;
import hawk.general_tools.adapters.Adapter;
import utest.Assert;
import utest.Async;

using yaku_core.test_utils.PromiseTestUtils;

class KVStoreAdapterTest extends utest.Test {
	public function testSetGet(async:utest.Async) {
		var store = createStore();
		store.set(123, 456).next(function(_) {
			return store.get(123);
		}).next(function(v) {
			Assert.equals(v, 456);
			return Noise;
		}).closeTestChain(async);
	}

	public function testGetMany(async:utest.Async) {
		var store = createStore();
		store.getMany([1, 2, 3, 7]).next(function(v) {
			v.sort(KVX.compareIntKeys);

			var expected = new Array<KV<Int, Null<Int>>>();
			expected.push(new KVC(1, 100));
			expected.push(new KVC(2, 200));
			expected.push(new KVC(3, 300));
			expected.push(new KVC(7, null));

			Assert.same(expected, v);
			return Noise;
		}).closeTestChain(async);
	}

	public function testIterator(async:utest.Async) {
		var store = createStore();
		var iterator = store.keyValueIterator();

		var actual = new Map<Int, Int>();
		AsyncIteratorX.forEach(iterator, function(kv) {
			actual.set(kv.key, kv.value);
			return Noise;
		}).next(function(_) {
			Assert.equals(100, actual[1]);
			Assert.equals(200, actual[2]);
			Assert.equals(300, actual[3]);
			return Noise;
		}).closeTestChain(async);
	}

	private function createStore():IKVStore<Int, Int> {
		var m = new Map<String, String>();
		m.set("1", "100");
		m.set("2", "200");
		m.set("3", "300");
		var localStore = new LocalMemKVStore(m);
		var intStringAdapter = new Adapter<Int, String>(Std.string, Std.parseInt);
		var store:IKVStore<Int, Int> = new KVStoreAdapter(intStringAdapter, intStringAdapter, localStore);
		return store;
	}
}
