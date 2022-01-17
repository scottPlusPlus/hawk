package hawk.store;

import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

using hawk.general_tools.adapters.AdapterX;

@:generic
class KVStoreReaderAdapter<K1, K2, V1, V2> implements IKVStoreReader<K1, V1> {
	private var _keyAdapter:Adapter<K1, K2>;
	private var _valAdapter:Adapter<V1, V2>;
	private var _wrappedStore:IKVStoreReader<K2, V2>;

	public function new(keyAdapter:Adapter<K1, K2>, valAdapter:Adapter<V1, V2>, store:IKVStore<K2, V2>) {
		_wrappedStore = store;
		_keyAdapter = keyAdapter;
		_valAdapter = valAdapter;
	}

	public function get(key:K1):Promise<Null<V1>> {
		var k2 = _keyAdapter.toB(key);
		var p = _wrappedStore.get(k2);
		return p.next(function(v2:Null<V2>) {
			if (v2 == null) {
				return Success(null);
			}
			var v1 = _valAdapter.toA(v2);
			return Success(v1);
		});
	}

	public function getMany(keys:Array<K1>):Promise<GetManyRes<K1,V1>> {
		var adaptedKeys = _keyAdapter.arrayToB(keys);
		return _wrappedStore.getMany(adaptedKeys).next(function(kvs){
			var adapter = new KVAdapter(_keyAdapter, _valAdapter.nullAdapter());
			var k1v1s = AdapterX.arrayToA(adapter, kvs);
			return k1v1s;
		});		
	}
}
