package hawk.store;

import hawk.store.*;
import zenlog.Log;
import tink.CoreApi;
import yaku_beta.dstruct.DoublyLinkedList;

using yaku_core.NullX;

class LRUCache<V> implements IKVStoreReader<String, V> implements IClientKVStore<String, V> {
	private var _cacheStore:IKVStore<String, V>;
	private var _truthStore:IKVStoreReader<String, V>;

	private var _lruKeys:DoublyLinkedList<String>;
	private var _lruNodes:Map<String, DLListNode<String>>;
	private var _capacity:UInt;

	public function new(cacheStore:IKVStore<String, V>, truthStore:IKVStoreReader<String, V>, capacity:UInt = 128) {
		_capacity = capacity;
		_lruKeys = new DoublyLinkedList();
		_cacheStore = cacheStore;
		_truthStore = truthStore;
		_lruNodes = new Map();
	}

	public function get(key:String):Promise<Null<V>> {
		return _cacheStore.get(key).next(function(localVal) {
			if (localVal != null) {
				Log.debug('got ${key} from local store == ${localVal}');
				var oldNode = _lruNodes.get(key).nullThrows();
				_lruKeys.removeNode(oldNode);
				var newNode = _lruKeys.push(key);
				_lruNodes.set(key, newNode);
				Log.debug('lru == ${_lruKeys}');
				return localVal;
			} // else, if item did not exist
			return _truthStore.get(key).next(function(trueVal) {
				Log.debug('got ${key} from backing store == ${trueVal}');
				_cacheStore.set(key, trueVal);
				var newNode = _lruKeys.push(key);
				_lruNodes.set(key, newNode);
				if (_lruKeys.length < _capacity) {
					return trueVal;
				}
				var oldestKey = _lruKeys.pop().nullThrows().item;
				return removeKey(oldestKey).next(function(_) {
					return trueVal;
				});
			});
		});
	}

	public function getMany(keys:Array<String>):Promise<Array<KV<String, Null<V>>>> {
		return _cacheStore.getMany(keys).next(function(cacheRes) {
			var res = cacheRes;
			var missedKeys = new Array<String>();
			var pendingRes = new Map<String, KV<String, Null<V>>>();
			for (kv in cacheRes) {
				if (kv.value == null) {
					missedKeys.push(kv.key);
					pendingRes.set(kv.key, kv);
				}
			}
			return _truthStore.getMany(missedKeys).next(function(trueRes) {
				for (kv in trueRes) {
					var pendingKV = pendingRes.get(kv.key).nullThrows('no pending Res for ${kv.key}');
					pendingKV.value = kv.value;
				}
				return res;
			});
		});
	}

	public function remove(key:String):Promise<Bool> {
		return removeKey(key);
	}

	private function removeKey(key:String):Promise<Bool> {
		_lruNodes.remove(key);
		return _cacheStore.remove(key);
	}

	public function set(key:String, value:V):Promise<V> {
		return _cacheStore.set(key, value);
	}
}
