package hawk.store;

import tink.CoreApi;

using hawk.util.PromiseX;

class IKVStoreX<K, V> {
	public static function getSure<K, V>(store:IKVStore<K, V>, key:K):Promise<V> {
		return store.get(key).errOnNull(new Error('no value for ${key}'));
	}
}
