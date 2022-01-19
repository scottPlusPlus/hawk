package hawk_test.store;

import tink.core.Noise;
import hawk.store.testutil.KVStoreReaderTester;
import tink.core.Promise;
import utest.Assert;
import yaku_core.test_utils.TestVals;
import hawk.store.LocalMemKVStore;
import hawk.store.LRUCache;

using yaku_core.test_utils.PromiseTestUtils;

class LRUCacheTest extends utest.Test {

    var _data:Map<String,String>;
    var _trueStore:KVStoreReaderTester<String,String>;
    var _lru: LRUCache<String>;

    public function setup(){
        _data = new Map<String,String>();
        _data.set(TestVals.key1, TestVals.val1);
        _data.set(TestVals.key2, TestVals.val2);
        var trueStore = new LocalMemKVStore(_data);
        _trueStore = new KVStoreReaderTester(trueStore);
        var cacheStore = new LocalMemKVStore(new Map<String,String>());
        _lru = new LRUCache(_trueStore, cacheStore);
    }

	public function testCaches(async:utest.Async) {
        return _lru.get(TestVals.key1).next(function(val){
            Assert.equals(TestVals.val1, val);
            Assert.equals(1, _trueStore.getTester.history.length);
            return Noise;
        }).next(function(_){
            return _lru.get(TestVals.key1).next(function(val){
                Assert.equals(TestVals.val1, val);
                //the second fetch should NOT hit the trueStore, it should come from the cache
                Assert.equals(1, _trueStore.getTester.history.length);
                return Noise;
            });
        }).closeTestChain(async);
    }
}