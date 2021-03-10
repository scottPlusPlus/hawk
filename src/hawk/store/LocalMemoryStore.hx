package hawk.store;

import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;


 // we only provide String/String to ensure types passed in are serializable
 // for a local store of different types, wrap LocalMemoryStore in an adapter
class LocalMemoryStore implements IKVStore<String,String> {
    
    private var _map:Map<String,String> = [];

    public function new(?map:Map<String,String>){
        if (map != null){
            _map = map;
        }
    }

    public function exists(key:String):Promise<Bool> {
        return _map.exists(key);
    }

	public function get(key:String):Promise<Null<String>>{
        return _map.get(key);
    }

    public function getMany(keys:Array<String>):Promise<Array<KV<String,Null<String>>>> {
        var kvs = new Array<KV<String,Null<String>>>();
        for (k in keys){
            var v = _map.get(k);
            var kv = new KVC(k, v);
            kvs.push(kv);
        }
        return kvs;
    }

	public function set(key:String, val:String):Promise<String>{
        _map.set(key, val);
        return  val;
    }

    // public function setMany(keyValues:Array<KV<String,String>>):Promise<Array<KV<String,String>>> {
    //     for (kv in keyValues){
    //         _map.set(kv.key, kv.value);
    //     }
    //     return keyValues;
    // }

	public function remove(key:String):Promise<Bool>{
        return _map.remove(key);
    }

    public function keyValueIterator():AsyncIterator<KV<String,String>> {
        var i = _map.keyValueIterator();
        return new AsyncIteratorWrapper(i);
    }
}