package hawk.store;

import tink.CoreApi;


 // we only provide String/String to ensure types passed in are serializable
 // for a local store of different types, wrap LocalMemoryStore in an adapter
class LocalMemoryStore implements IKVStore<String,String> {
    
    private var _map:Map<String,String> = [];

    public function new(){}

    public function exists(key:String):Promise<Bool> {
        return _map.exists(key);
    }

	public function get(key:String):Promise<Null<String>>{
        return _map.get(key);
    }

	public function getSure(key:String):Promise<String>{
        var v = _map.get(key);
        if (v == null){
            return Failure(new Error('no value for ${key}'));
        }
        return Success(v);
    }

	public function set(key:String, val:String):Promise<String>{
        _map.set(key, val);
        return  val;
    }

	public function remove(key:String):Promise<Bool>{
        return _map.remove(key);
    }
}