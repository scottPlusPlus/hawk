package hawk.store.postgres;

import zenlog.Log;
import tink.CoreApi;

using hawk.util.ErrorX;

class PostgresDatatoreFactory implements IDataStoreFactory {
	private var _postgres:Dynamic;
	private var _onNewStoreTrigger:SignalTrigger<DataStoreWithName>;

	public var onNewStore(get, never):Signal<DataStoreWithName>;

	public function get_onNewStore():Signal<DataStoreWithName> {
		return _onNewStoreTrigger.asSignal();
	}

	public function new(postgres:Dynamic) {
		_postgres = postgres;
		_onNewStoreTrigger = new SignalTrigger();
	}

	public function get<T>(name:String, model:DataModel<T>):Promise<IDataStore<T>> {
		return genStore(name, model).next(function(store) {
			var adapter = DataModelX.stringAdapter(model);
			var stringStore = new DataStoreAdapter(adapter, store);
			_onNewStoreTrigger.trigger({ 
				name: name,
				store: stringStore
			});
			return store;
		});
	}

	private inline function genStore<T>(name:String, model:DataModel<T>):Promise<IDataStore<T>> {
		if (_postgres == null) {
			return genLocalStore(name, model);
		}
		return genPostgesStore(name, model).recover(function(err) {
			Log.error(err.wrap('Failed to init postgres store ${name}.  Will use LocalStore as fallback'));
			_postgres = null;
			return genLocalStore(name, model);
		});
	}

	private function genPostgesStore<T>(name:String, model:DataModel<T>):Promise<IDataStore<T>> {
		var store = new PostgresDataStore(_postgres, name, model);
		return store.init().next(function(pgs){
			var istore:IDataStore<T> = store;
			return Success(istore);
		});
	}

	private function genLocalStore<T>(name:String, model:DataModel<T>):IDataStore<T> {
		var store:IDataStore<T> = new LocalDataStore(model);
		var iface:IDataStore<T> = store;
		return iface;
	}

}

typedef DataStoreWithName = {
	name:String,
	store:IDataStore<String>
}
