package hawk_test.store;

import yaku_core.test_utils.TestVals;
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

        var truthData = new Map<String,String>();
        truthData.set(TestVals.key1, TestVals.val1);
        truthData.set(TestVals.key2, TestVals.val2);
        var truthStore = new LocalMemKVStore(truthData);

        var clientStore = ClientKVStore.createLocalMemCacheStringKey(truthStore.getMany);
        clientStore.get(TestVals.key1).next(function(val){
            Assert.equals(TestVals.val1, val);
            return Noise;
        }).closeTestChain(async);
    }
}