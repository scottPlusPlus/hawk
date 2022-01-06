package hawk.store;

import hawk.async_iterator.AsyncIterator;
import tink.CoreApi.Promise;

interface  IKVStoreReader<K, V> {
	function get(key:K):Promise<Null<V>>;
	function getMany(keys:Array<K>):Promise<GetManyRes<K,V>>;
}
