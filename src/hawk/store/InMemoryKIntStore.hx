package hawk.store;

import haxe.Constraints.IMap;
import hawk.general_tools.adapters.*;
import tink.CoreApi.Promise;
import zenlog.Log;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Outcome;

@:generic
class InMemoryKIntStore<K> implements  IKIntStore<K> {

    public function new(adapter:Adapter<K,String>){
        _data = new MapAdapterK<K,String,Int>(adapter, new Map<String,Int>());
    }

    private var _data:IMap<K,Int>;

    public function get(key:K):Promise<Null<Int>>{
        var val = _data.get(key);
        return Success(val);
    }

    public function getSure(key:K):Promise<Int> {
        return get(key).next(function(val:Null<Int>){
            if (val == null){
                return Failure(new Error('no value for ${key}'));
            }
            return Success(val);
        });
    }

    public function set(key:K, value:Int):Promise<Int>{
        _data.set(key,value);
        return Success(value);
    }
    
    public function remove(key:K):Promise<Bool>{
        var r = _data.remove(key);
        return Success(r);
    }

    public function add(key:K, value:Int, d:Int=0):Promise<Int> {
        var current = _data.get(key);
        if (current == null){
            current = d;
        }
        var sum = current + value;
        _data.set(key, sum);
        return Success(sum);
    }

    public function exists(key:K):Promise<Bool>{
        var exists = _data.exists(key);
        return Success(exists);
    }
}