package hawk.store;


import hawk.util.Batcher;
import tink.CoreApi;

class ClientKVStore {
	public static inline function createLocalMemCacheStringKey<V>(getManyWebRequest:Array<String>->Promise<GetManyRes<String,V>>, batchDelayMS:UInt = 100, cacheCount:UInt = 128):LRUCache<V> {

		var localMap = new Map<String,V>();
		var localStore = new LocalMemKVStore(localMap);

		var batcher = new Batcher<Null<V>>(getManyWebRequest, batchDelayMS);
		var fetchMany = function(keys:Array<String>):Promise<GetManyRes<String,V>> {
			return IKVStoreX.getMany(keys, batcher.request);
		}
		var fetcher = new CustomKVReader<String, V>(batcher.request, fetchMany);
		return new LRUCache(localStore, fetcher, cacheCount);
	}
}