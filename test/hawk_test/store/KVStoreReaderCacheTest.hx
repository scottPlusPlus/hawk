package hawk_test.store;

import tink.CoreApi;
import yaku_core.test_utils.TestVals;
import hawk.store.LocalKVStore;
import hawk.store.KVStoreReaderLRUCache;
import hawk.store.IKVStoreReader;
import hawk.store.IKVStore; 
import utest.Assert;
import utest.Async;
import zenlog.Log;

using yaku_core.test_utils.PromiseTestUtils;

class KVStoreReaderCacheTest extends utest.Test {
	public function testHappy(async:utest.Async) {
		var agg = createAggregate();
		return Promise.resolve(Noise).next(function(_) {
			return agg.cacheStore.get(TestVals.key1).next(function(val) {
				Assert.equals(TestVals.val1, val);
				return Noise;
			});
		}).next(function(_) {
			// remove value from the backing store, to show we're getting it from the cache
			agg.backingMap.clear();
			return agg.cacheStore.get(TestVals.key1).next(function(val) {
				Assert.equals(TestVals.val1, val);
				return Noise;
			});
		}).closeTestChain(async);
	}

	public function testGetMany(async:utest.Async) {
		var agg = createAggregate();
		return Promise.resolve(Noise).next(function(_) {
			return agg.cacheStore.getMany([TestVals.key1, TestVals.key2, TestVals.key3]).next(function(res) {
				for (kv in res) {
					Assert.notNull(kv.value);
					var expected = agg.backingMap.get(kv.key);
					Assert.equals(expected, kv.value);
				}
				return Noise;
			});
		}).next(function(_) {
			// remove value from the backing store, to show we're getting it from the cache
			agg.backingMap.clear();
			return agg.cacheStore.get(TestVals.key2).next(function(val) {
				Assert.equals(TestVals.val2, val);
				return Noise;
			});
		}).closeTestChain(async);
	}

	public function testRespectsCapacity(async:utest.Async) {
		var agg = createAggregate();
		var cache = new KVStoreReaderLRUCache(agg.localStore, agg.backingStore, 2);
		return Promise.NOISE.next(function(_) {
			return cache.getMany([TestVals.key1, TestVals.key2, TestVals.key3]).next(function(res) {
				for (kv in res) {
					Assert.notNull(kv.value);
					var expected = agg.backingMap.get(kv.key);
					Assert.equals(expected, kv.value);
				}
				return Noise;
			});
		}).next(function(_) {
			agg.backingMap.clear();
			Log.debug("testRespectsCapacity: get key1 again...");
			return agg.cacheStore.get(TestVals.key1).next(function(val) {
				// Key1 should fall out of capacity,
				// thus needs to be pulled from the backing store, which is empty
				Assert.isNull(val);
				return Noise;
			});
		}).closeTestChain(async);
	}

	public function createAggregate():Aggregate {
		var local = new LocalKVStore();
		var backingMap = new Map<String, String>();
		backingMap.set(TestVals.key1, TestVals.val1);
		backingMap.set(TestVals.key2, TestVals.val2);
		backingMap.set(TestVals.key3, TestVals.val3);
		var backing = new LocalKVStore(backingMap);
		var cache = new KVStoreReaderLRUCache(local, backing);
		return {
			localStore: local,
			backingMap: backingMap,
			backingStore: backing,
			cacheStore: cache
		}
	}
}

typedef Aggregate = {
	localStore:IKVStore<String, String>,
	backingMap:Map<String, String>,
	backingStore:IKVStore<String, String>,
	cacheStore:KVStoreReaderLRUCache<String, String>
}
