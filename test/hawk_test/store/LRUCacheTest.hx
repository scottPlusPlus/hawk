package hawk_test.store;

import hawk.store.KVX;
import tink.core.Noise;
import hawk.store.testutil.KVStoreReaderTester;
import tink.core.Promise;
import utest.Assert;
import yaku_core.test_utils.TestVals;
import hawk.store.LocalMemKVStore;
import hawk.store.LRUCache;

using yaku_core.test_utils.PromiseTestUtils;
using hawk.store.KVCX;

class LRUCacheTest extends utest.Test {

    var _data:Map<String,String>;
    var _trueStore:KVStoreReaderTester<String,String>;
    var _lru: LRUCache<String>;

    public function setup(){
        _data = new Map<String,String>();
        _data.set(TestVals.key1, TestVals.val1);
        _data.set(TestVals.key2, TestVals.val2);
        _data.set(TestVals.key3, TestVals.val3);
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

    public function testCachesMany(async:utest.Async) {
        return _lru.get(TestVals.key1)
        .next(function(_){
            return _lru.getMany([TestVals.key1, TestVals.key2, TestVals.key3]).next(function(res){
                Assert.equals(1, _trueStore.getTester.history.length);
                Assert.equals(1, _trueStore.getManyTester.history.length);

                var m = KVX.toMap(res, new Map<String,String>());
                Assert.equals(TestVals.val1, m.get(TestVals.key1));
                Assert.equals(TestVals.val2, m.get(TestVals.key2));
                Assert.equals(TestVals.val3, m.get(TestVals.key3));
                return Noise;
            });
        }).next(function(_){
            var promises = [
                _lru.get(TestVals.key1),
                _lru.get(TestVals.key2),
                _lru.get(TestVals.key3),
            ];
            return Promise.inParallel(promises).next(function(_){
                Assert.equals(1, _trueStore.getTester.history.length);
                return Noise;
            });
        }).closeTestChain(async);
    }

    public function testTrueNulls(async:utest.Async) {
        return _lru.get("missing_key").next(function(val){
            Assert.equals(null, val);
            return Noise;
        }).next(function(_){
            var missedKey = "another_missed_key";
            return _lru.getMany([TestVals.key1, missedKey, TestVals.key2]).next(function(res){
                var m = KVX.toMap(res, new Map<String,String>());
                Assert.equals(TestVals.val1, m.get(TestVals.key1));
                Assert.equals(null, m.get(missedKey));
                Assert.equals(TestVals.val2, m.get(TestVals.key2));
                return Noise;
            });
        }).closeTestChain(async);
    }
}