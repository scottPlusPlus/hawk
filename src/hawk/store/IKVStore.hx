package hawk.store;

import hawk.async_iterator.AsyncIterator;
import tink.CoreApi.Promise;

interface  IKVStore<K, V> extends IKVStoreReader<K,V> extends IClientKVStore<K,V> extends IKVStoreReader<K,V> {

	function get(key:K):Promise<Null<V>>;
	function set(key:K, value:V):Promise<V>;
	function remove(key:K):Promise<Bool>;

	function keyValueIterator():AsyncIterator<KV<K,V>>;
	function getMany(keys:Array<K>):Promise<GetManyRes<K,V>>;

	//unclear what the expected failure-behavior for a setMany would be...
	//function setMany(keyValues:Array<KV<K,V>>):Promise<Array<KV<K,V>>>;
}
