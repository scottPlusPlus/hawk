package hawk_test.store;

import tink.core.Noise;
import hawk.store.LocalMemoryStore;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;

class LocalMemoryStoreTest extends utest.Test {

	public function testHappy(async:utest.Async) {
	
        var store = new LocalMemoryStore();
        var foo = "foo";
        var foo2 = "footwo";
        var bar = "bar";

        store.set(foo, bar).next(function(v:String){
            Assert.equals(bar, v);
            
            return store.exists(foo);
        }).next(function(v:Bool){
            Assert.equals(true, v);

            return store.exists("asdf");
        }).next(function(v:Bool){
            Assert.equals(false, v);

            return store.get("adsf");
        }).next(function(v:Null<String>){
            Assert.equals(null, v);

            return store.get(foo);   
        }).next(function(v:Null<String>){
            Assert.equals(bar, v);

            return store.getSure(foo);   
        }).next(function(v:String){
            Assert.equals(bar, v);

            return store.remove(foo);
        }).next(function(v:Bool){
            Assert.equals(true, v);

            return store.exists(foo); 
        }).next(function(v:Bool){
            Assert.equals(false, v);

            return store.set(bar, foo);
        }).next(function(v:String){
            Assert.equals(foo, v);
        
            return store.set(bar, foo2);
        }).next(function(v:String){
            Assert.equals(foo2, v);

            return store.getSure(bar);
        }).next(function(v:String){
            Assert.equals(foo2, v);
            return Noise;
        }).closeTestChain(async);
    }

}