package hawk.store;

import tink.CoreApi.Promise;
import zenlog.Log;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Outcome;

@:generic
class InMemoryKIntStore<K> implements  IKIntStore<K> {

    public function new(ser:KSerializer<K>){
        _data = new Map();
        _keyToStr = ser.toString;
    }

    private var _data:Map<String,Int>;
    private var _keyToStr: K->String;


    public function get(key:K):Promise<Int>{
        var kstr = _keyToStr(key);
        var val = _data.get(kstr);
        if (val == null){
            return Failure(new Error( 'key ${key} doesnt exist'));
        }
        return Success(val);
    }

    public function set(key:K, value:Int):Promise<Int>{
        var kstr = _keyToStr(key);
        _data.set(kstr,value);
        return Success(value);
    }
    
    public function remove(key:K):Promise<Noise>{
        var kstr = _keyToStr(key);
        _data.remove(kstr);
        return Success(Noise);
    }

    public function add(key:K, value:Int, d:Int=0):Promise<Int> {
        var kstr = _keyToStr(key);
        var current = _data.get(kstr);
        if (current == null){
            current = d;
        }
        var sum = current + value;
        _data.set(kstr, sum);
        return Success(sum);
    }

    public function exists(key:K):Promise<Bool>{
        var kstr = _keyToStr(key);
        var ex = _data.exists(kstr);
        return Success(ex);
    }
}

typedef KSerializer<K> = {
    toString: K->String,
    fromString: String->K
}