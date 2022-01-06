package hawk_test.store;

import hawk.store.LocalDataStore;
import yaku_core.test_utils.TestVals;
import tink.CoreApi;
import hawk.store.KeyBlobStore;
import utest.Assert;
import utest.Async;

using yaku_core.test_utils.PromiseTestUtils;

class KeyBlobStoreTest  extends utest.Test {

	public function testHappy(async:utest.Async) {
	
        var model = KeyBlobStore.model();
        var backingStore = new LocalDataStore(model);
        var keyBlobStore = new KeyBlobStore(backingStore);

        var stringStore:KeyBlobStringStore;

        return keyBlobStore.buildStringStore("xyz").next(function(store){
            stringStore = store;
            return Noise;
        }).next(function(_){
            return stringStore.save(TestVals.gibberish).next(function(v:String){
                Assert.equals(TestVals.gibberish, v);
                return Noise;
            });
        }).next(function(_){
            return stringStore.load().next(function(v:String){
                Assert.equals(TestVals.gibberish, v);
                return Noise;
            });
        }).closeTestChain(async);
    }
}
