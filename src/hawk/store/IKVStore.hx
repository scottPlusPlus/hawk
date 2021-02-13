package hawk.store;

import tink.CoreApi.Promise;

interface IKVStore<K, V> {
	function exists(key:K):Promise<Bool>;
	function get(key:K):Promise<Null<V>>;
	function getSure(key:K):Promise<V>;
	function set(key:K, value:V):Promise<V>;
	function remove(key:K):Promise<Bool>;
}
