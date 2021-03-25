package hawk.store.postgres;

import zenlog.Log;
import tink.CoreApi;

using hawk.util.ErrorX;

class PostgresKVStoreFactory implements IKVStoreFactory {
	private var _postgres:Dynamic;
	private var _onNewStoreTrigger:SignalTrigger<KVStoreWithName>;

	public var onNewStore(get, never):Signal<KVStoreWithName>;

	public function get_onNewStore():Signal<KVStoreWithName> {
		return _onNewStoreTrigger.asSignal();
	}

	public function new(postgres:Dynamic) {
		_postgres = postgres;
		_onNewStoreTrigger = new SignalTrigger();
	}

	public function get(name:String):Promise<IKVStore<String, String>> {
		return genStore(name).next(function(store) {
			_onNewStoreTrigger.trigger({
				name: name,
				store: store
			});
			return store;
		});
	}

	private inline function genStore(name:String):Promise<IKVStore<String, String>> {
		if (_postgres == null) {
			return genLocalStore(name);
		}
		return genPostgesStore(name).recover(function(err) {
			Log.error(err.wrap('Failed to init postgres store ${name}.  Will use LocalStore as fallback'));
			_postgres = null;
			return genLocalStore(name);
		});
	}

	private function genPostgesStore(name:String):Promise<IKVStore<String, String>> {
		var store = new PostgresKVStore(_postgres, name);
		return store.init().next(function(res) {
			var iface:IKVStore<String, String> = res;
			return iface;
		});
	}

	private function genLocalStore(name:String):IKVStore<String, String> {
		var store = new LocalKVStore();
		var iface:IKVStore<String, String> = store;
		return iface;
	}
}

typedef KVStoreWithName = {
	name:String,
	store:IKVStore<String, String>
}
