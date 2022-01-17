package hawk_test.store;

import hawk.store.GetManyRes;
import utest.Async;
import hawk.general_tools.adapters.SelfAdapter;
import hawk.store.KVStoreAdapter;
import hawk.general_tools.adapters.CommonAdapters;
import hawk.store.ClientKVStore;
import haxe.Constraints.IMap;
import tink.CoreApi;
import hawk.store.LocalMemKVStore;
import utest.Assert;

using hawk.store.KVX;
using yaku_core.test_utils.PromiseTestUtils;

class ClientKVStoreTest  extends utest.Test {

    public function testHappy(async:utest.Async){

        var intStringAdapter = CommonAdapters.stringIntAdapter().invert();
        var stringStringAdapter = SelfAdapter.create();

        var truthMap = new Map<String,String>();
        var truthStore = new LocalMemKVStore(truthMap);
        var truthIntStore = new KVStoreAdapter(intStringAdapter, stringStringAdapter, truthStore);

        var clientStore = ClientKVStore.createLocalMemCacheIntKey(truthIntStore.getMany);
        var expected = "one";
        truthMap.set("1", expected );
        clientStore.get(1).next(function(val){
            Assert.equals(expected, val);
            return Noise;
        }).closeTestChain(async);
    }
}