package hawk.store;

import tink.CoreApi;

using hawk.util.PromiseX;

class IKVStoreX {

	public static function getOrErr<K, V>(store:IKVStore<K, V>, key:K):Promise<V> {
		return store.get(key).errOnNull(new Error('no value for ${key}'));
	}

	public static function getOrFallback<K,V>(store:IKVStore<K, V>, key:K, fallback:V):Promise<V> {
		return store.get(key).next(function(maybe){
			if (maybe == null){
				return Success(fallback);
			}
			return maybe;
		});
	}
 
	public static function push<K,V>(store:IKVStore<K,Array<V>>, key:K, val:V):Promise<Array<V>>{
		return IKVStoreX.getOrFallback(store, key, []).next(function(arr){
			arr.push(val);
			return store.set(key, arr);
		});
	}

}
