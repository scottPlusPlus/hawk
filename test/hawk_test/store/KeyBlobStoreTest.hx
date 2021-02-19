package hawk_test.store;

import hawk.testutils.TestVals;
import tink.CoreApi;
import hawk.store.KeyBlobStore;
import hawk.store.LocalMemoryStore;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;

class KeyBlobStoreTest  extends utest.Test {

	public function testHappy(async:utest.Async) {
	
        var backingStore = new LocalMemoryStore();
        var keyBlobStore = new KeyBlobStore(backingStore);

        var stringStore = keyBlobStore.buildStringStore("xyz");

        stringStore.save(TestVals.gibberish).next(function(v:String){
            Assert.equals(TestVals.gibberish, v);
            return stringStore.load();
        }).next(function(v:String){
            Assert.equals(TestVals.gibberish, v);
            return Noise;
        }).closeTestChain(async);
    }
}
