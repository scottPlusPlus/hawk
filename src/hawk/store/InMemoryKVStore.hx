package hawk.store;

import tink.CoreApi.Promise;
import zenlog.Log;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Outcome;

@:generic
class InMemoryKVPStore<K, V> implements  IKVStore<K, V> {

    public function new(ser:KVSerializer<K,V>){
        _data = new Map();
        _keyToStr = ser.keyToStr;
        _valToStr = ser.valToStr;
        _valFromStr = ser.valFromStr;
    }

    private var _data:Map<String,String>;
    private var _keyToStr: K->String;
    private var _valToStr: V->String;
    private var _valFromStr: String->V;

    public function get(key:K):Promise<Null<V>>{
        var kstr = _keyToStr(key);
        var vstr = _data.get(kstr);
        if (vstr == null){
            return Success(null);
        }
        Log.info('kvp store get ${kstr} == ${vstr}');
        var val = _valFromStr(vstr);
        return Success(val);
    }

    public function set(key:K, value:V):Promise<Noise>{
        var kstr = _keyToStr(key);
        var vstr = _valToStr(value);
        //Log.info('kvp store set ${kstr} == ${vstr}');
        _data.set(kstr,vstr);
        return Success(Noise);
    }
    
    public function remove(key:K):Promise<Noise>{
        var kstr = _keyToStr(key);
        _data.remove(kstr);
        return Success(Noise);
    }

    public function exists(key:K):Promise<Bool>{
        var kstr = _keyToStr(key);
        var ex = _data.exists(kstr);
        return Success(ex);
    }
}

typedef KVSerializer<K,V> = {
    keyToStr: K->String,
    valToStr: V->String,
    valFromStr: String->V
}