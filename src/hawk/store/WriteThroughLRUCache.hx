package hawk.store;

import hawk.async_iterator.AsyncIterator;
import tink.core.Promise;

class WriteThroughLRUCache<V> extends LRUCache<V> implements IKVStore<String,V> {

    private var _fullTruthStore:IKVStore<String,V>;

    public function new(truthStore:IKVStore<String, V>, ?cacheStore:IKVStore<String, V>, capacity:UInt = 128) {
        super(truthStore, cacheStore, capacity);
        _fullTruthStore = truthStore;   
    }

	public override function set(key:String, value:V):Promise<V> {
        return _fullTruthStore.set(key, value).next(function(res){
            return _cacheStore.set(key, value);
        });
	}

    public function keyValueIterator():AsyncIterator<KV<String,V>>{
        return _fullTruthStore.keyValueIterator();
    }
}