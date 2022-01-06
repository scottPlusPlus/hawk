package hawk.store;

import tink.CoreApi;

using yaku_core.PromiseX;

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

	public static inline function getMany<K,V>(keys:Array<K>, getMethod:K->Promise<Null<V>>):Promise<GetManyRes<K,V>> {
		var getPromises = new Array<Promise<KV<K, Null<V>>>>();
		for (k in keys) {
			var p = getMethod(k).next(function(ns):KV<K, Null<V>> {
				return new KVC(k, ns);
			});
			getPromises.push(p);
		}
		var res = Promise.inSequence(getPromises);
		return res;
	}

}
