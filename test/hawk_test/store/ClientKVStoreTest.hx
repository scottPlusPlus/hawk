package hawk_test.store;

import utest.Async;
import hawk.general_tools.adapters.SelfAdapter;
import hawk.store.KVStoreAdapter;
import hawk.general_tools.adapters.CommonAdapters;
import hawk.store.ClientKVStore;
import haxe.Constraints.IMap;
import tink.CoreApi;
import hawk.store.LocalKVStore;
import utest.Assert;

using hawk.store.KVX;
using hawk.testutils.PromiseTestUtils;

class ClientKVStoreTest  extends utest.Test {

    public function testHappy(async:utest.Async){

        var intStringAdapter = CommonAdapters.stringIntAdapter().invert();
        var stringStringAdapter = SelfAdapter.create();

        var localMap = new Map<String,String>();
        var localStore = new LocalKVStore(localMap);
        var localIntStore = new KVStoreAdapter(intStringAdapter, stringStringAdapter, localStore);

        var fetchMany = function(keys:Array<Int>):Promise<IMap<Int, String>> {
            return localIntStore.getMany(keys).next(function(kvs){
                var emptyMap = new Map<Int,String>();
                return kvs.toMap(emptyMap);
            });
        }

        var clientStore = ClientKVStore.create(intStringAdapter, stringStringAdapter, fetchMany);
        var expected = "one";
        localMap.set("1", expected );
        clientStore.get(1).next(function(val){
            Assert.equals(expected, val);
            return Noise;
        }).closeTestChain(async);
    }
}