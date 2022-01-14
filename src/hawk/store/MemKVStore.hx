package hawk.store;

import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;


 // In-Memory KV Store.  (it's a map)
class MemKVStore<K,V> implements IKVStore<K,V> {
    
    private var _map:Map<K,V> = [];

    public function new(?map:Map<K,V>){
        if (map != null){
            _map = map;
        }
    }

    public function exists(key:K):Promise<Bool> {
        return _map.exists(key);
    }

	public function get(key:K):Promise<Null<V>>{
        return _map.get(key);
    }

    public function getMany(keys:Array<K>):Promise<GetManyRes<K,V>> {
        var kvs = new GetManyRes<K,V>();
        for (k in keys){
            var v = _map.get(k);
            var kv = new KVC(k, v);
            kvs.push(kv);
        }
        return kvs;
    }

	public function set(key:K, val:V):Promise<V>{
        _map.set(key, val);
        return  val;
    }

	public function remove(key:K):Promise<Bool>{
        return _map.remove(key);
    }

    public function keyValueIterator():AsyncIterator<KV<K,V>> {
        var i = _map.keyValueIterator();
        return new AsyncIteratorWrapper(i);
    }
}