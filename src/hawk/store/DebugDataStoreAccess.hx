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
			case "get":
				return s.getIndexByColName(column).get(key).next(function(di) {
					return di.value();
				});

			case "create":
				if (quote.length > 0){
					value = StringTools.replace(value, quote, '"');
				}
				return s.create(value).next(function(di) {
					return di.value();
				});

			case "delete":
				return s.getIndexByColName(column).get(key).next(function(di) {
					if (di == null) {
						return Promise.resolve("no such item");
					}
					return di.delete().next(function(_) {
						return Promise.resolve("item deleted");
					});
				});

			case "print":
				return printAll(s);

			case "drop":
				return dropAll(s, key);

			default:
				return Failure(new Error('dont recognize command ${command}.  Try exists, get, set, remove'));
		}
	}

	private function printAll(store:IDataStore<String>):Promise<String> {
		var str = "";
		var it = store.iterator();
		return AsyncIteratorX.forEach(it, function(di:IDataItem<String>) {
			str += '${di.value()}\n';
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
		var allItems = new Array<IDataItem<String>>();
		var it = store.iterator();
		return AsyncIteratorX.forEach(it, function(di:IDataItem<String>) {
			allItems.push(di);
			return Promise.NOISE;
		}).next(function(_) {
			var asyncKeys = new AsyncIteratorWrapper(allItems.iterator());
			var dp = AsyncIteratorX.forEach(asyncKeys, function(di:IDataItem<String>) {
				Log.debug('dropping ${di.value()}');
				return di.delete();
			});
			return dp;
		}).next(function(_) {
			return "done";
		});
	}
}
