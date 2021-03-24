package hawk.store;

import tink.CoreApi;
import hawk.store.IKVStore;

interface IKVStoreFactory {
    function get(name:String):Promise<IKVStore<String,String>>;
}