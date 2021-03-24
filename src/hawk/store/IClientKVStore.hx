package hawk.store;

import hawk.async_iterator.AsyncIterator;
import tink.CoreApi.Promise;

interface  IClientKVStore<K, V> {

	function get(key:K):Promise<Null<V>>;
	function set(key:K, value:V):Promise<V>;
	function remove(key:K):Promise<Bool>;
	function getMany(keys:Array<K>):Promise<Array<KV<K,Null<V>>>>;

}
