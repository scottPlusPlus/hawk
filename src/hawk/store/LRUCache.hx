package hawk.store;

import hawk.store.*;
import zenlog.Log;
import tink.CoreApi;
import yaku_beta.dstruct.DoublyLinkedList;

using yaku_core.NullX;

class LRUCache<K, V> implements IKVStoreReader<K,V> implements IClientKVStore<K,V> {
	private var _cacheStore:IKVStore<K, V>;
	private var _truthStore:IKVStoreReader<K,V>;

	private var _lruKeys:DoublyLinkedList<K>;
    private var _lruNodes: Map<K,DLListNode<K>>;
	private var _capacity:UInt;

	public function new(cacheStore:IKVStore<K, V>, truthStore:IKVStoreReader<K,V>, capacity:UInt = 128) {
		_capacity = capacity;
		_lruKeys = new DoublyLinkedList();
		_cacheStore = cacheStore;
		_truthStore = truthStore;
	}

	public function get(key:K):Promise<Null<V>> {
        return _cacheStore.get(key).next(function(localVal){
            if (localVal != null) {
                Log.debug('got ${key} from local store == ${localVal}');
                var oldNode = _lruNodes.get(key).nullThrows();
                _lruKeys.removeNode(oldNode);
                var newNode = _lruKeys.push(key);
                _lruNodes.set(key, newNode);
                Log.debug('lru == ${_lruKeys}');
                return localVal;
            } //else, if item did not exist
            return _truthStore.get(key).next(function(trueVal) {
                Log.debug('got ${key} from backing store == ${trueVal}');
                _cacheStore.set(key, trueVal);
                var newNode = _lruKeys.push(key);
                _lruNodes.set(key, newNode);
                if (_lruKeys.length < _capacity) {
                    return trueVal;
                }
                var oldestKey = _lruKeys.pop().nullThrows().item;
                return removeKey(oldestKey).next(function(_){
                    return trueVal;
                });
            });
        });
	}

	public function getMany(keys:Array<K>):Promise<Array<KV<K, Null<V>>>> {
        return _cacheStore.getMany(keys).next(function(cacheRes){
            var res = cacheRes;
            var missedKeys = new Array<K>();
            var pendingRes = new Map<K,KV<K,Null<V>>>();
            for(kv in cacheRes){
                if (kv.value == null){
                    missedKeys.push(kv.key);
                    pendingRes.set(kv.key, kv);
                }
            }
            return _truthStore.getMany(missedKeys).next(function(trueRes){
                for(kv in trueRes){
                    var pendingKV = pendingRes.get(kv.key).nullThrows('no pending Res for ${kv.key}');
                    pendingKV.value = kv.value;
                }
                return res;
            });
        });
	}

	public function remove(key:K):Promise<Bool> {
		return removeKey(key);
	}

    private function removeKey(key:K):Promise<Bool> {
        _lruNodes.remove(key);
        return _cacheStore.remove(key);
    }

    public function set(key:K, value:V):Promise<V> {
        return _cacheStore.set(key, value);
    }
}
