package hawk.store;

import tink.CoreApi;

using hawk.util.NullX;

class DebugStoreAccess {
	private var _stores:Map<String, IKVStore<String, String>> = [];

	public function new(){}

	public function register(storeName:String, store:IKVStore<String, String>) {
		_stores.set(storeName, store);
	}

	public function query(command:String, store:String, key:String = "", val:String = ""):Promise<String> {
		var s = _stores.get(store);
		if (s == null) {
            var keys = "";
            for (k in _stores.keys()){
                keys += k + ", ";
            }
			return Failure(new Error('no store registered for ${store}.  Have:  ${keys}'));
		}

		command = StringTools.trim(command.toLowerCase());

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

			default:
				return Failure(new Error('dont recognize command ${command}.  Try exists, get, set, remove'));
		}
	}
}
