package hawk.store.testutil;

import tink.core.Promise;
import yaku_core.test_utils.MockWrapFunction;

class KVStoreReaderTester<K,V> implements IKVStoreReader<K,V> {

    public var store: IKVStore<K,V>;

    public var getTester:MockWrapFunction<K,Promise<Null<V>>>;
    public var getManyTester:MockWrapFunction<Array<K>,Promise<GetManyRes<K,V>>>;

    public function new (store:IKVStore<K,V>){
        this.store = store;
        getTester = new MockWrapFunction(store.get);
        getManyTester = new MockWrapFunction(store.getMany);
    }

    public function get(key:K):Promise<Null<V>>{
        return getTester.call(key);

    }
	public function getMany(keys:Array<K>):Promise<GetManyRes<K,V>>{
        return getManyTester.call(keys);
    }
    
}