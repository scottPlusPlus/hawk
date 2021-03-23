package hawk.store;

import zenlog.Log;
import tink.CoreApi;

class KVStoreReaderLRUCache<K, V> implements IKVStoreReader<K,V> {
	private var _localStore:IKVStore<K, V>;
	private var _backingStore:IKVStoreReader<K, V>;

	private var _lruKeys:List<K>;
	private var _capacity:UInt;

	public function new(local:IKVStore<K, V>, backing:IKVStoreReader<K, V>, capacity:UInt = 32) {
		_capacity = capacity;
		_lruKeys = new List<K>();
		_localStore = local;
		_backingStore = backing;
	}

	public function get(key:K):Promise<Null<V>> {
        return _localStore.get(key).next(function(localVal){
            if (localVal != null) {
                Log.debug('got ${key} from local store == ${localVal}');
                _lruKeys.remove(key);
                _lruKeys.add(key);
                Log.debug('lru == ${_lruKeys}');
                return localVal;
            }
            return _backingStore.get(key).next(function(backingVal) {
                Log.debug('got ${key} from backing store == ${backingVal}');
                _localStore.set(key, backingVal);
                _lruKeys.add(key);
                if (_lruKeys.length > _capacity) {
                    var oldest = _lruKeys.pop();
                    return _localStore.remove(oldest).next(function(_){
                        Log.debug('killed ${oldest} from localStore');
                        return backingVal;
                    });
                }
                Log.debug('lru == ${_lruKeys}');
                return backingVal;
            });
        });
	}

	public function getMany(keys:Array<K>):Promise<Array<KV<K, Null<V>>>> {
		var res = new Array<KV<K, Null<V>>>();
		var promises = new Array<Promise<Noise>>();
		for (key in keys) {
			var p = get(key).next(function(nv) {
				var kvc = new KVC(key, nv);
				res.push(kvc);
				return Noise;
			});
			promises.push(p);
		}
		return Promise.inParallel(promises).next(function(_) {
			return res;
		});
	}

	public function remove(key:K):Promise<Bool> {
		return _localStore.remove(key);
	}
}
