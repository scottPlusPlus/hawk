package hawk_test.store;

import hawk.store.IKVStore;
import hawk.store.WriteThroughLRUCache;
import tink.core.Noise;
import hawk.store.testutil.KVStoreReaderTester;
import tink.core.Promise;
import utest.Assert;
import yaku_core.test_utils.TestVals;
import hawk.store.LocalMemKVStore;
import hawk.store.LRUCache;

using yaku_core.test_utils.PromiseTestUtils;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

class WriteThroughLRUCacheTest extends utest.Test {

    // var _data:Map<String,String>;
    // var _trueStore:hawk.store.LocalMemKVStoreMocked<String, String>;
    // var _lru: WriteThroughLRUCache<String>;

    // public function setup(){
    //     _data = TestVals.mapWithKVP_0to9();
    //     var trueStore = new LocalMemKVStore(_data);
    //     _trueStore = new KVStoreReaderTester(trueStore);
    //     var cacheStore = new LocalMemKVStore(new Map<String,String>());
    //     _lru = new LRUCache(_trueStore, cacheStore);
    // }

    @:access(hawk.store.LocalMemKVStoreMocked)
    public function testMockatoo(async:utest.Async){
        var myStore = spy(LocalMemKVStore, [String,String]);
        var data = new Map<String,String>();
        myStore.myMap = data;

        var someMock:hawk.store.LocalMemKVStoreMocked<String, String> = myStore;
        return myStore.set("foo","bar").next(function(_){
            return myStore.get("foo").next(function(val){
                Assert.equals("bar", val);
                return Noise;
            });
        }).closeTestChain(async);
    }


	// public function testCaches(async:utest.Async) {
    //     return _lru.get(TestVals.key1).next(function(val){
    //         Assert.equals(TestVals.val1, val);
    //         Assert.equals(1, _trueStore.getTester.history.length);
    //         return Noise;
    //     }).next(function(_){
    //         return _lru.get(TestVals.key1).next(function(val){
    //             Assert.equals(TestVals.val1, val);
    //             //the second fetch should NOT hit the trueStore, it should come from the cache
    //             Assert.equals(1, _trueStore.getTester.history.length);
    //             return Noise;
    //         });
    //     }).closeTestChain(async);
    // }

    

}