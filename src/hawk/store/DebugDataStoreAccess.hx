package hawk.store;

import zenlog.Log;
import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.datatypes.UUID;
import hawk.async_iterator.AsyncIteratorX;
import tink.CoreApi;

class DebugDataStoreAccess {
	private final DROP = "drop";
	private var _dropKey:String;

	private var _stores:Map<String, IDataStore<String>> = [];

	public function new() {}

	public function register(storeName:String, store:IDataStore<String>) {
		_stores.set(storeName, store);
	}

	public function query(command:String, store:String, column:String = "", key:String = "", value:String = "", quote:String=""):Promise<String> {
		Log.debug('DebugDataStoreAccess.query:  cmd=${command}  store=${store}  col=${column}  key=${key}  val=${value}  quote=${quote}');
		
		var s = _stores.get(store);
		if (s == null) {
			var keys = "";
			for (k in _stores.keys()) {
				keys += k + ", ";
			}
			return Failure(new Error('no store registered for ${store}.  Have:  ${keys}'));
		}

		if (quote.length > 0){
			value = StringTools.replace(value, quote, '"');
		}

		command = StringTools.trim(command.toLowerCase());
		if (_dropKey != "" && command != DROP) {
			_dropKey = "";
		}

		switch command {
			case "get":
				return s.getIndexByColName(column).get(key);

			case "create":
				return s.create(value);

			case "update":
				return s.update(value);

			case "delete":
				return s.getIndexByColName(column).get(key).next(function(obj) {
					if (obj == null) {
						return Promise.resolve("no such item");
					}
					return s.delete(obj).next(function(_) {
						return Promise.resolve("item deleted");
					});
				});

			case "print":
				return printAll(s);

			case "drop":
				return dropAll(s, key);

			default:
				return Failure(new Error('dont recognize command ${command}.  Try get, create, delete, print, drop'));
		}
	}

	private function printAll(store:IDataStore<String>):Promise<String> {
		var str = "";
		var it = store.iterator();
		return AsyncIteratorX.forEach(it, function(obj:String) {
			str += '${obj}\n';
			return Promise.NOISE;
		}).next(function(_) {
			return str;
		});
	}

	private function dropAll(store:IDataStore<String>, key:String):Promise<String> {
		if (_dropKey == "") {
			_dropKey = UUID.gen();
			return 'Are you sure you want to clear all data from the store?  Submit again with key = ${_dropKey}';
		}
		if (key != _dropKey) {
			_dropKey = "";
			return 'wrong key, try again';
		}
		var allItems = new Array<String>();
		var it = store.iterator();
		return AsyncIteratorX.forEach(it, function(item:String) {
			allItems.push(item);
			return Promise.NOISE;
		}).next(function(_) {
			var asyncKeys = new AsyncIteratorWrapper(allItems.iterator());
			var dp = AsyncIteratorX.forEach(asyncKeys, function(item:String) {
				store.delete(item);
				Log.debug('dropping ${item}');
				return store.delete(item);
			});
			return dp;
		}).next(function(_) {
			return "done";
		});
	}
}
