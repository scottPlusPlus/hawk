package hawk.store;


import hawk.util.Batcher;
import tink.CoreApi;

class ClientKVStore {
	// public static inline function createLocalMemCache<K, V>(getManyWebRequest:Array<K>->Promise<GetManyRes<K,V>>, localMap:Map<K,V>, batchDelayMS:UInt = 100, cacheCount:UInt = 128):LRUCache<K, V> {

	// 	//var localMap = new Map<K,V>();
	// 	var localStore = new LocalMemKVStore(localMap);

	// 	var m = new Map<K,PromiseTrigger<Null<V>>>();
	// 	var batcher = new Batcher<K,Null<V>>(getManyWebRequest, batchDelayMS, m);
	// 	var fetchMany = function(keys:Array<K>):Promise<GetManyRes<K,V>> {
	// 		return IKVStoreX.getMany(keys, batcher.request);
	// 	}
	// 	var fetcher = new CustomKVReader<K, V>(batcher.request, fetchMany);
	// 	return new LRUCache(localStore, fetcher, cacheCount);
	// }

	public static inline function createLocalMemCacheStringKey<V>(getManyWebRequest:Array<String>->Promise<GetManyRes<String,V>>, batchDelayMS:UInt = 100, cacheCount:UInt = 128):LRUCache<String, V> {

		var localMap = new Map<String,V>();
		var localStore = new LocalMemKVStore(localMap);

		var m = new Map<String,PromiseTrigger<Null<V>>>();
		var batcher = new Batcher<String,Null<V>>(getManyWebRequest, batchDelayMS, m);
		var fetchMany = function(keys:Array<String>):Promise<GetManyRes<String,V>> {
			return IKVStoreX.getMany(keys, batcher.request);
		}
		var fetcher = new CustomKVReader<String, V>(batcher.request, fetchMany);
		return new LRUCache(localStore, fetcher, cacheCount);
	}

	public static inline function createLocalMemCacheIntKey<V>(getManyWebRequest:Array<Int>->Promise<GetManyRes<Int,V>>, batchDelayMS:UInt = 100, cacheCount:UInt = 128):LRUCache<Int, V> {

		var localMap = new Map<Int,V>();
		var localStore = new LocalMemKVStore(localMap);

		var m = new Map<Int,PromiseTrigger<Null<V>>>();
		var batcher = new Batcher<Int,Null<V>>(getManyWebRequest, batchDelayMS, m);
		var fetchMany = function(keys:Array<Int>):Promise<GetManyRes<Int,V>> {
			return IKVStoreX.getMany(keys, batcher.request);
		}
		var fetcher = new CustomKVReader<Int, V>(batcher.request, fetchMany);
		return new LRUCache(localStore, fetcher, cacheCount);
	}
}