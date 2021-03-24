package hawk.store;

import hawk.store.IKVStore;
import tink.CoreApi;
import hawk.store.LocalKVStore;

class LocalKVStoreFactory implements IKVStoreFactory {

    private var _map:Map<String,LocalKVStore> = [];

    public function new(){}

    public function get(name:String):Promise<IKVStore<String,String>>{
        if (_map.exists(name)){
            var err = new Error('IKVStore ${name} was already created. Only use IKVStoreFactory to create NEW stores');
            return err;
        }
        var store = new LocalKVStore();
        _map.set(name, store);
        var iface:IKVStore<String,String> = store;
        return iface;
    }
}