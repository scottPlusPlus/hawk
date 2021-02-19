package hawk.store;

import zenlog.Log;
import tink.CoreApi;

class KeyBlobStore {
	private var _store:IKVStore<String, String>;
	private var _built:Map<String, UInt> = [];

	public function new(store:IKVStore<String, String>) {
		_store = store;
	}

	public function buildStringStore(key:String) :IStringStore {
		if (_built.exists(key)) {
			Log.error('StringStore for key ${key} has already been created.  If you need to access that store from multiple places, best to pass it around.');
		}
		_built.set(key, 0);
		var s = new KeyBlobStringStore(_store, key);
		return s;
	}
}

class KeyBlobStringStore implements IStringStore {
	private var _store:IKVStore<String, String>;
	private var _key:String;

	public function new(store:IKVStore<String, String>, key:String) {
		_store = store;
		_key = key;
	}

	public function load():Promise<String> {
		return _store.get(_key).next(function(ns:Null<String>) {
			if (ns == null) {
				return "";
			}
			return ns;
		});
	}

	public function save(data:String):Promise<String> {
		return _store.set(_key, data);
	}
}
