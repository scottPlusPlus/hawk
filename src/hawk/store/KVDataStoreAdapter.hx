package hawk.store;

import tink.CoreApi;

class KVStoreFromDataStore<K,V> {

    private var _dataStore:IDataStore<V>;
    private var _dataStoreIndex:IDataStoreIndex<K,V>;

    public function new(dataStore:IDataStore<V>, index:IDataStoreIndex<K,V>){
        _dataStore = dataStore;
        _dataStoreIndex = index;
    }

	function get(key:K):Promise<Null<V>> {
        return _dataStoreIndex.get(key);
    }
	// function set(key:K, value:V):Promise<V> {

    // }

	// function remove(key:K):Promise<Bool> {
    //     return 
    //     var obj = 
    // }

	// function keyValueIterator():AsyncIterator<KV<K,V>>;
	// function getMany(keys:Array<K>):Promise<Array<KV<K,Null<V>>>>;

}