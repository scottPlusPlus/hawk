package hawk.store;

import hawk.store.IKVStore;
import tink.CoreApi;
import hawk.store.LocalMemKVStore;

class LocalMemKVStoreFactory implements IKVStoreFactory {

    private var _map:Map<String,LocalMemKVStore<String,String>> = [];

    public function new(){}

    public function get(name:String):Promise<IKVStore<String,String>>{
        if (_map.exists(name)){
            var err = new Error('IKVStore ${name} was already created. Only use IKVStoreFactory to create NEW stores');
            return err;
        }
        var store = new LocalMemKVStore(new Map<String,String>());
        _map.set(name, store);
        var iface:IKVStore<String,String> = store;
        return iface;
    }
}