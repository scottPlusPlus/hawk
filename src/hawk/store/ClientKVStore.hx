package hawk.store;

import hawk.general_tools.adapters.MapAdapterK;
import hawk.util.Batcher;
import tink.CoreApi;
import hawk.general_tools.adapters.TStringAdapter;
import haxe.Constraints.IMap;

class ClientKVStore {
	public static function create<K, V>(keyAdapter:TStringAdapter<K>, valAdapter:TStringAdapter<V>,
			getManyWebRequest:Array<K>->Promise<IMap<K, V>>):KVStoreReaderLRUCache<K, V> {
		var localStoreStr = new LocalKVStore();
		var localStore = new KVStoreAdapter(keyAdapter, valAdapter, localStoreStr);

		var createMap = function() {
			var map = new Map<String, PromiseTrigger<Null<V>>>();
			var adaptedMap = new MapAdapterK(keyAdapter, map);
			return adaptedMap;
		}

		var batcher = new Batcher(getManyWebRequest, 100, createMap);
		var fetcher = new CustomFetcher<K, V>(batcher.request);
		return new KVStoreReaderLRUCache(localStore, fetcher, 32);
	}
}

class CustomFetcher<K, V> implements IKVStoreReader<K, V> {
	private var _fetch:K->Promise<Null<V>>;

	public function new(fetch:K->Promise<Null<V>>) {
		_fetch = fetch;
	}

	public function get(key:K):Promise<Null<V>> {
		return _fetch(key);
	}

	public function getMany(keys:Array<K>):Promise<Array<KV<K, Null<V>>>> {
		return IKVStoreX.getMany(keys, _fetch);
	}
}
