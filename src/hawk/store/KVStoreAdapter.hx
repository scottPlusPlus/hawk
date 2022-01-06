package hawk.store;

import hawk.async_iterator.AsyncIteratorAdapter;
import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;
import hawk.async_iterator.AsyncIterator;

using hawk.general_tools.adapters.AdapterX;

@:generic
class KVStoreAdapter<K1, K2, V1, V2> implements IKVStore<K1, V1> {
	private var _keyAdapter:Adapter<K1, K2>;
	private var _valAdapter:Adapter<V1, V2>;
	private var _wrappedStore:IKVStore<K2, V2>;

	private var _kvAdapter:KVAdapter<K1,V1,K2,V2>;

	public function new(keyAdapter:Adapter<K1, K2>, valAdapter:Adapter<V1, V2>, store:IKVStore<K2, V2>) {
		_wrappedStore = store;
		_keyAdapter = keyAdapter;
		_valAdapter = valAdapter;
		_kvAdapter = new  KVAdapter(_keyAdapter, _valAdapter);
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

	public function set(key:K1, value:V1):Promise<V1> {
		var k2 = _keyAdapter.toB(key);
		var v2 = _valAdapter.toB(value);
		return _wrappedStore.set(k2, v2).next(function(_) {
			return Success(value);
		});
	}

	public function remove(key:K1):Promise<Bool> {
		var k2 = _keyAdapter.toB(key);
		return _wrappedStore.remove(k2);
	}

	public function keyValueIterator():AsyncIterator<KV<K1,V1>>{
		var iterator =  new AsyncIteratorAdapter(_kvAdapter, _wrappedStore.keyValueIterator());
		return iterator;
	}
}
