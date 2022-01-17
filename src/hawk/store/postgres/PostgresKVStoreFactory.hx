package hawk.store.postgres;

import yaku_core.PromiseX;
import zenlog.Log;
import tink.CoreApi;

using yaku_core.ErrorX;
using yaku_core.PromiseX;

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
		return PromiseX.tryOrErr(function(){
			Log.debug('attempt genPostgresStore for ${name}');
			return genPostgresStore(name).withTimeout(2000);
		}).recover(function(err) {
			Log.error(err.wrap('Failed to init postgres store ${name}.  Will use LocalStore as fallback'));
			_postgres = null;
			return genLocalStore(name);
		});
	}

	private function genPostgresStore(name:String):Promise<IKVStore<String, String>> {
		var store = new PostgresKVStore(_postgres, name);
		return store.init().next(function(res) {
			var iface:IKVStore<String, String> = res;
			return iface;
		});
	}

	private function genLocalStore(name:String):IKVStore<String, String> {
		var store = new LocalMemKVStore(new Map<String,String>());
		return store;
	}
}

typedef KVStoreWithName = {
	name:String,
	store:IKVStore<String, String>
}
