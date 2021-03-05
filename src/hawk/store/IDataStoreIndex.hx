package hawk.store;

import hawk.store.ArrayKV;
import tink.CoreApi;

interface IDataStoreIndex<K,V> {
    function get(key:K): Promise<Null<V>>;
    function getMany(keys:Array<K>): Promise<ArrayKV<K,Null<V>>>;
}