package hawk.store;

import haxe.Constraints.IMap;
import hawk.general_tools.adapters.*;
import tink.CoreApi.Promise;
import zenlog.Log;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Outcome;

@:generic
class InMemoryKVStore<K, V> implements  IKVStore<K, V> {

    public function new(keyAdapter: TStringAdapter<K>, valAdapter:TStringAdapter<V>){
        // we enforce storing as String/String to ensure types passed in are serializable
        var map = new Map<String,String>();
        _data = new MapAdapterKV<K,String,V,String>(keyAdapter, valAdapter, map);
    }

    private var _data:IMap<K,V>;

    public function exists(key:K):Promise<Bool>{
        var exists = _data.exists(key);
        return Success(exists);
    }

    public function get(key:K):Promise<Null<V>>{
        var r = _data.get(key);
        return Success(r);
    }

    public function getSure(key:K):Promise<V> {
        return get(key).next(function(val:Null<V>){
            if (val == null){
                return Failure(new Error('no value for ${key}'));
            }
            return Success(val);
        });
    }

    public function set(key:K, value:V):Promise<V>{
        _data.set(key,value);
        return Success(value);
    }
    
    public function remove(key:K):Promise<Bool>{
        var r = _data.remove(key);
        return Success(r);
    }
}