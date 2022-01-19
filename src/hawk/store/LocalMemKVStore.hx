package hawk.store;

import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;


 // In-Memory KV Store.  (it's a map)
class LocalMemKVStore<K,V> implements IKVStore<K,V> {
    
    private var myMap:Map<K,V>;

    public function new(map:Map<K,V>){
        myMap = map;
    }

    public function exists(key:K):Promise<Bool> {
        return myMap.exists(key);
    }

	public function get(key:K):Promise<Null<V>>{
        return myMap.get(key);
    }

    public function getMany(keys:Array<K>):Promise<GetManyRes<K,V>> {
        var kvs = new GetManyRes<K,V>();
        for (k in keys){
            var v = myMap.get(k);
            var kv = new KVC(k, v);
            kvs.push(kv);
        }
        return kvs;
    }

	public function set(key:K, val:V):Promise<V>{
        myMap.set(key, val);
        return  val;
    }

	public function remove(key:K):Promise<Bool>{
        return myMap.remove(key);
    }

    public function keyValueIterator():AsyncIterator<KV<K,V>> {
        var i = myMap.keyValueIterator();
        return new AsyncIteratorWrapper(i);
    }

    public static function newStringStore():LocalMemKVStore<String,String> {
        return new LocalMemKVStore(new Map<String,String>());
    }
}