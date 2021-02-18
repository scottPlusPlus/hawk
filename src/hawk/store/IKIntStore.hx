package hawk.store;

import tink.CoreApi.Promise;

interface IKIntStore<K> {
	function exists(key:K):Promise<Bool>;
	function get(key:K):Promise<Null<Int>>;
	function getSure(key:K):Promise<Int>;
	function set(key:K, value:Int):Promise<Int>;
	function add(key:K, value:Int, d:Int = 0):Promise<Int>;
	function remove(key:K):Promise<Bool>;
}
