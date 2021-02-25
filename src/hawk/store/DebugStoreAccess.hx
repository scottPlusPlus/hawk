package hawk.store;

import zenlog.Log;
import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.datatypes.UUID;
import hawk.async_iterator.AsyncIteratorX;
import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;

using hawk.util.NullX;

class DebugStoreAccess {
	private final DROP = "drop";

	private var _stores:Map<String, IKVStore<String, String>> = [];

	private var _dropKey:String;

	public function new() {}

	public function register(storeName:String, store:IKVStore<String, String>) {
		_stores.set(storeName, store);
	}

	public function query(command:String, store:String, key:String = "", val:String = ""):Promise<String> {
		var s = _stores.get(store);
		if (s == null) {
			var keys = "";
			for (k in _stores.keys()) {
				keys += k + ", ";
			}
			return Failure(new Error('no store registered for ${store}.  Have:  ${keys}'));
		}

		command = StringTools.trim(command.toLowerCase());
		if (_dropKey != "" && command != DROP) {
			_dropKey = "";
		}

		switch command {
			case "exists":
				return s.exists(key).next(function(b:Bool) {
					return Std.string(b);
				});

			case "get":
				return s.get(key);

			case "set":
				return s.set(key, val);

			case "remove":
				return s.remove(key).next(function(b:Bool) {
					return Std.string(b);
				});

			case "print":
				return printAll(s);

			case "drop":
				return dropAll(s, key);

			default:
				return Failure(new Error('dont recognize command ${command}.  Try exists, get, set, remove'));
		}
	}

	private function printAll(store:IKVStore<String, String>):Promise<String> {
		var str = "";
		var it = store.keyValueIterator();
		return AsyncIteratorX.forEach(it, function(kv:KV<String, String>) {
			str += '${kv.key}:  ${kv.value}\n';
			return Promise.NOISE;
		}).next(function(_) {
			return str;
		});
	}

	private function dropAll(store:IKVStore<String, String>, key:String):Promise<String> {
		if (_dropKey == "") {
			_dropKey = UUID.gen();
			return 'Are you sure you want to drop all?  Submit again with key = ${_dropKey}';
		}
		if (key != _dropKey) {
			_dropKey = "";
			return 'wrong key, try again';
		}
		var allKeys = new Array<String>();
		var it = store.keyValueIterator();
		return AsyncIteratorX.forEach(it, function(kv:KV<String, String>) {
			allKeys.push(kv.key);
			return Promise.NOISE;
		}).next(function(_) {
			var asyncKeys = new AsyncIteratorWrapper(allKeys.iterator());
			var dp = AsyncIteratorX.forEach(asyncKeys, function(k:String) {
				Log.debug('dropping ${k}');
				return store.remove(key).noise();
			});
			return dp;
		}).next(function(_) {
			return "done";
		});
	}
}
